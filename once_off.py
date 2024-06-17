import os
import pandas as pd
import numpy as np
import gpxpy
import geopy.distance
from geopy.geocoders import Nominatim
from tqdm import tqdm
import pickle

# Define the directory containing the GPX files
data_dir = 'data'

# Define the path for the DataFrame pickle file
df_path = 'sessions_data4.pkl'

# Initialize the geocoder
geolocator = Nominatim(user_agent="gpx_analyzer")

# Function to parse a GPX file and return a DataFrame
def parse_gpx(file_path):
    with open(file_path, 'r') as gpx_file:
        gpx = gpxpy.parse(gpx_file)

    track_data = []
    for track in gpx.tracks:
        for segment in track.segments:
            for point in segment.points:
                track_data.append({
                    'latitude': point.latitude,
                    'longitude': point.longitude,
                    'elevation': point.elevation,
                    'time': point.time
                })

    return pd.DataFrame(track_data)

# Function to get the country of the first GPS point
def get_country(lat, lon):
    location = geolocator.reverse((lat, lon), language='en', exactly_one=True)
    if location and 'country' in location.raw['address']:
        return location.raw['address']['country']
    return None

# Function to calculate the percentage of distance on foil
def get_foil_metrics(filename, min_foil_speed):
    df = parse_gpx(filename)
    first_coord = (df.iloc[0]['latitude'], df.iloc[0]['longitude'])
    country = get_country(*first_coord)

    # Calculate distances between consecutive points
    coords = [(p.latitude, p.longitude) for p in df.itertuples()]
    df['distance'] = [0] + [geopy.distance.distance(from_, to).m for from_, to in zip(coords[:-1], coords[1:])]
    df['cumulative_distance'] = df['distance'].cumsum()

    # Calculate speed and foil status
    df['duration'] = df['time'].diff().dt.total_seconds().fillna(0)
    df['speed'] = (df['distance'] / df['duration']) * 3.6  # Convert m/s to km/h
    df['avg_speed'] = df['speed'].rolling(15).mean()
    df['status'] = np.where(df['avg_speed'] > min_foil_speed, 1, 0)
    distance = sum(df['distance'])

    # Calculate distance on and off foil
    distance_on_foil = df.loc[df['status'] == 1, 'distance'].sum()
    distance_off_foil = df.loc[df['status'] == 0, 'distance'].sum()
    total_distance = distance_on_foil + distance_off_foil
    distance_percentage_on_foil = (distance_on_foil / total_distance) * 100 if total_distance > 0 else 0

    # Categorize location if in the Netherlands
    location_category = None
    if country == 'Netherlands':
        if first_coord[1] > 4.855175:
            location_category = 'lakes'
        else:
            location_category = 'North Sea'

    return {
        'filename': filename,
        'distance_percentage_on_foil': distance_percentage_on_foil,
        'first_coord': first_coord,
        'country': country,
        'location_category': location_category,
        'distance': distance
    }

# Load the existing DataFrame if it exists
if os.path.exists(df_path):
    with open(df_path, 'rb') as f:
        sessions = pickle.load(f)
else:
    sessions = pd.DataFrame(columns=['filename', 'distance_percentage_on_foil', 'first_coord', 'country', 'location_category'])

# Get list of all GPX files in the data directory
gpx_files = [os.path.join(data_dir, f) for f in os.listdir(data_dir) if f.endswith('.gpx')]

# Get list of already processed files
processed_files = sessions['filename'].tolist()

# Filter out already processed files
new_files = [f for f in gpx_files if f not in processed_files]

# Process each new GPX file and update the DataFrame
min_foil_speed = 10  # Define minimum foil speed as per your requirement
new_rows = []
for file in tqdm(new_files, desc="Processing GPX files"):
    metrics = get_foil_metrics(file, min_foil_speed)
    new_rows.append(metrics)

# Append new rows to the DataFrame
if new_rows:
    sessions = pd.concat([sessions, pd.DataFrame(new_rows)], ignore_index=True)

# Save the updated DataFrame to a pickle file
with open(df_path, 'wb') as f:
    pickle.dump(sessions, f)

# Display the updated DataFrame
sessions


sessions.to_clipboard(excel=True, index=False)
