import geopy.distance
import gpxpy
import numpy as np
import re
import pandas as pd
from os import walk
import os
from datetime import datetime
from geopy.distance import great_circle
#define dataframe
sessions = pd.DataFrame(columns = ['session_name', 'distance', 'distance_percentage_on_foil', 'time_percentage_on_foil', 'starts', 'distance_per_start','distance_on_foil', 'max_foil_distance', 'median_foil_distance', 'avg_speed', 'on_foil_last_4_sessions', 'extra_distance_max_km_percentage', 'cumulative_distance_on_foil', 'cumulative_distance_off_foil', 'filename', 'fastest_kilometer_full_km', 'slowest_kilometer_time_on_foil', 'extra_distance_total_percentage', 'lat_lon_points'])

def extract_lat_lon_points(df, num_points=20):
    total_points = len(df)

    def calculate_speed(df):
        speeds = [0]
        for i in range(1, len(df)):
            point1 = (df.iloc[i - 1]['latitude'], df.iloc[i - 1]['longitude'])
            point2 = (df.iloc[i]['latitude'], df.iloc[i]['longitude'])
            distance = great_circle(point1, point2).meters
            time_diff = (df.iloc[i]['time'] - df.iloc[i - 1]['time']).total_seconds()
            speed = (distance / time_diff) * 3.6 if time_diff != 0 else 0  # Multiply by 3.6 to convert m/s to km/h
            speeds.append(speed)
        return speeds

    df['speed'] = calculate_speed(df)

    if total_points <= num_points:
        lat_lon_points = df[['time', 'latitude', 'longitude', 'speed']].to_dict('records')
        for point in lat_lon_points:
            point['time'] = point['time'].strftime('%Y-%m-%d %H:%M:%S')
        return lat_lon_points

    step = (total_points - 1) // (num_points - 1)

    lat_lon_points = []
    for i in range(0, total_points, step)[:num_points]:
        point = df.iloc[i]
        lat_lon_points.append({
            'time': point['time'].strftime('%Y-%m-%d %H:%M:%S'),
            'latitude': point['latitude'],
            'longitude': point['longitude'],
            'speed': point['speed']
        })

    return lat_lon_points

def get_metrics(filename, min_foil_speed):

    gpx_path = filename

    with open(gpx_path) as f:
        gpx = gpxpy.parse(f)

    # Convert to a dataframe one point at a time.
    points = []
    for segment in gpx.tracks[0].segments:
        for p in segment.points:
            points.append({
                'time': p.time,
                'latitude': p.latitude,
                'longitude': p.longitude,

            })
    df = pd.DataFrame.from_records(points)
    session_name = df.iloc[0, 0]





    # Cumulative distance.
    coords = [(p.latitude, p.longitude) for p in df.itertuples()]
    df['distance'] = [0] + [geopy.distance.distance(from_, to).m for from_, to in zip(coords[:-1], coords[1:])]
    df['cumulative_distance'] = df.distance.cumsum()

    # Timing.
    df['duration'] = df.time.diff().dt.total_seconds().fillna(0)
    df['cumulative_duration'] = df.duration.cumsum()
    df['speed_metric'] = pd.Series((df.distance / 1000)/(df.duration / 3600)).bfill()

    # Drop missing speed values and reset index
    df['speed_metric'].replace([np.inf, -np.inf], np.nan, inplace=True)
    df.dropna(subset=['speed_metric'], how="all", inplace=True)
    df.reset_index(drop=True, inplace=True)

    #calc avg speed and foil status
    df['avg_speed'] = df['speed_metric'].rolling(15).mean()
    df['status'] = np.where(df['avg_speed'] > min_foil_speed, 1, 0)

    #indicate start and end of foil sections
    df_prev = df.shift(1)['status']
    df_next = df.shift(-1)['status']
    df_next2 = df.shift(-2)['status']
    df.loc[(df_prev != 1) & (df['status'] == 1) & (df_next == 1), 'start'] = 1
    df.loc[(df['status'] != 0) & (df_next == 0) & (df_next2 == 0), 'end'] = 1
    df.fillna(0, inplace=True)
    df = df.astype({"start":"int","end":"int"})

    #cumulative starts
    df['cumulative_starts'] = df['start'].cumsum()
    df['foil_section'] = df['status'] * df['cumulative_starts']



    #time on foil
    time_on_foil = df.loc[df['status'] == 1, 'duration'].sum()
    time_off_foil = df.loc[df['status'] == 0, 'duration'].sum()
    time_percentage_on_foil = (time_on_foil / (time_on_foil + time_off_foil)).round(2)

    distance_on_foil = (df.loc[df['status'] == 1, 'distance'].sum()).round(0)
    distance_off_foil = (df.loc[df['status'] == 0, 'distance'].sum()).round(0)
    distance = (distance_on_foil + distance_off_foil).round(0)
    distance_percentage_on_foil = (distance_on_foil / (distance_on_foil + distance_off_foil)).round(2)

    #speed
    avg_speed = ((distance/1000) / ((time_on_foil+time_off_foil)/60/60)).round(1)




    starts = df.loc[df['start'] == 1, 'status'].count()
    ends = df.loc[df['end'] == 1, 'status'].count()
    distance_per_start = (distance_on_foil / starts).round(0)
    foil_time_per_start = time_on_foil / starts / 60
    distance_per_off_foil = (distance_off_foil / ends).round(0)
    distance_on_foil = (distance * distance_percentage_on_foil).round(0)

    #max foil distance
    df_group = df.groupby(['status','foil_section']).sum('distance')
    df_group =df_group[df_group['start'] !=0]
    max_foil_distance = (df_group['distance'].max()).round(0)
    median_foil_distance = (df_group['distance'].median()).round(0)


    step = 5  # Set the step size, e.g., 5 means every 5th data point is considered
    window_size = 1000  # meters
    max_extra_distance = 0
    max_extra_distance_start_index = None

    i = 0
    while i < len(df) - 1:
        if df.loc[i, 'status'] == 1:
            distance_sum = 0
            end_index = i
            while distance_sum < window_size and end_index < len(df) - 1:
                if df.loc[end_index, 'status'] == 1:
                    distance_sum += df.loc[end_index, 'distance']
                    end_index += 1
                else:
                    i = end_index  # Move i to the next status=1 section
                    break

            if distance_sum >= window_size:
                first_coord = (df.loc[i, 'latitude'], df.loc[i, 'longitude'])
                last_coord = (df.loc[end_index - 1, 'latitude'], df.loc[end_index - 1, 'longitude'])
                straight_line_distance = geopy.distance.distance(first_coord, last_coord).m

                extra_distance = distance_sum - straight_line_distance
                if extra_distance > max_extra_distance:
                    max_extra_distance = extra_distance
                    max_extra_distance_start_index = i
        i += step

    extra_distance_max_km_percentage = (max_extra_distance/1000)
    # Check if the value is 0 and replace it with NaN
    if extra_distance_max_km_percentage == 0:
        extra_distance_max_km_percentage = np.nan

        # Fastest full kilometer
    window_size = 1000  # meters
    min_time_full_km = None
    min_start_index_full_km = None
    num_full_kms = int(df['cumulative_distance'].iloc[-1] // window_size)

    for i in range(0, num_full_kms):
        start_index = df[df['cumulative_distance'] >= i * window_size].index[0]
        end_index = df[df['cumulative_distance'] >= (i + 1) * window_size].index[0]

        time_for_1000m = df.loc[end_index, 'cumulative_duration'] - df.loc[start_index, 'cumulative_duration']
        if min_time_full_km is None or time_for_1000m < min_time_full_km:
            min_time_full_km = time_for_1000m
            min_start_index_full_km = start_index

    # Convert min_time_full_km to minutes and seconds (mm:ss)
    fastest_kilometer_full_km = min_time_full_km


    step = 20
    # Slowest kilometer time while on foil
    window_size = 1000  # meters
    max_time_on_foil = None
    max_start_index_on_foil = None

    i = 0
    while i < len(df) - 1:
        if df.loc[i, 'status'] == 1:
            distance_sum = 0
            end_index = i
            while distance_sum < window_size and end_index < len(df) - 1:
                if df.loc[end_index, 'status'] == 1:
                    distance_sum += df.loc[end_index, 'distance']
                    end_index += 1
                else:
                    i = end_index  # Move i to the next status=1 section
                    break

            if distance_sum >= window_size:
                time_for_1000m = df.loc[end_index - 1, 'cumulative_duration'] - df.loc[i, 'cumulative_duration']
                if max_time_on_foil is None or time_for_1000m > max_time_on_foil:
                    max_time_on_foil = time_for_1000m
                    max_start_index_on_foil = i
        i += step


    slowest_kilometer_on_foil = max_time_on_foil






    # Calculate straight line distance between the first and last coordinates
    first_coord = (df.iloc[0]['latitude'], df.iloc[0]['longitude'])
    last_coord = (df.iloc[-1]['latitude'], df.iloc[-1]['longitude'])
    straight_line_distance = geopy.distance.distance(first_coord, last_coord).m  # meters

    # Calculate the total distance covered from the DataFrame
    total_distance_covered = df['cumulative_distance'].iloc[-1]

    # Compare the distance covered with the straight line distance
    extra_distance_total_percentage = (total_distance_covered / straight_line_distance-1).round(2)

    lat_lon_points = extract_lat_lon_points(df)



    on_foil_last_4_sessions = 0

    cumulative_distance_on_foil = 0
    cumulative_distance_off_foil = 0


    new_row = [session_name, distance, distance_percentage_on_foil, time_percentage_on_foil, starts, distance_per_start, distance_on_foil, max_foil_distance, median_foil_distance, avg_speed, on_foil_last_4_sessions, extra_distance_max_km_percentage, cumulative_distance_on_foil, cumulative_distance_off_foil, filename, fastest_kilometer_full_km, slowest_kilometer_on_foil, extra_distance_total_percentage, lat_lon_points]
    return new_row



