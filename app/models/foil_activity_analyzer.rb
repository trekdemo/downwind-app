# frozen_string_literal: true

# The daru gem has a bunch of warnings that are not relevant to this project.
original_verbosity = $VERBOSE
$VERBOSE = nil
require "daru"
$VERBOSE = original_verbosity
require "gpx"
require "geocoder"

# TODO: Most probably it would be better to write this class using the
# ActiveStorage::Analyzer
# https://github.com/rails/rails/blob/main/activestorage/lib/active_storage/analyzer.rb
# Rails can register these types and automatically run them for the uploaded
# file.
class FoilActivityAnalyzer
  attr_reader :gpx_file, :lift_speed, :data_frame

  # Creates an analyzer to analyze the GPX file
  # @param gpx_file [IO] file in GPX format
  # @param lift_speed [Numeric] The speed which marks take off
  def initialize(gpx_file, lift_speed)
    @gpx_file = gpx_file
    @lift_speed = lift_speed

    @data_frame = Daru::DataFrame.new(trackpoints).tap do |df|
      df[:distance_cumsum_m] = df[:distance_m].cumsum

      # On foil when the average speed is above the lift speed for the window
      df[:on_foil] = Daru::Vector.new(rolling_speed(df).map { |speed| speed > lift_speed / 3.6 ? 1 : 0 }, index: df.index)
    end
  end

  def inspect
    "#<#{self.class.name} trackpoints=#{trackpoints.size} lift_speed=#{lift_speed}>"
  end

  def metadata
    {
      started_at:,
      ended_at:,
      duration:,
      starts:,
      time_on_foil:,
      distance_total:,
      distance_on_foil:,
      speed_avg:,
      speed_max:,
      speed_avg_on_foil:,
      hr_avg:,
      hr_max:,
      fastest_full_km:,
      fastest_full_10km:,
      route_bounds:,
      route_preview:
    }
  end

  # TODO: These are the features needed to be implemented
  # - [ ] Distance per start (m)
  # - [ ] Max distance per start (m)
  # - [ ] Cumulative distance off foil (km)
  # - [ ] fastest_kilometer_full_km
  # - [ ] slowest_kilometer_full_km

  def started_at = data_frame[:timestamp].min
  def ended_at = data_frame[:timestamp].max
  def duration = data_frame[:timestamp].range
  def distance_total = data_frame[:distance_cumsum_m].max

  def starts = data_frame[:on_foil].diff.count(1)

  def speed_avg = data_frame[:speed_m_s].mean
  def speed_max = data_frame[:speed_m_s].max

  def hr_avg = data_frame[:hr].mean
  def hr_max = data_frame[:hr].max

  # On foil stats
  def time_on_foil                = on_foil[:elapsed_sec].sum || 0
  def time_on_foil_percentage     = time_on_foil / duration * 100
  def distance_on_foil            = on_foil[:distance_m].sum || 0
  def distance_on_foil_percentage = distance_on_foil / total_distance * 100

  def speed_avg_on_foil = on_foil[:speed_m_s].mean || 0

  def fastest_kilometer_on_foil
    dist = on_foil[:distance_cumsum_m]
    on_foil.map_rows do |start|
      one_km = on_foil.where(dist.gt(start[:distance_cumsum_m] + 1_000)).first
      one_km[:timestamp] - start[:timestamp]
    end
  end

  def fastest_full_km = fastest_full_distance(1_000)
  def fastest_full_10km = fastest_full_distance(10_000)

  def route_bounds
    south, north = *data_frame[:lat].minmax
    west, east = *data_frame[:lon].minmax

    { "north" => north, "south" => south, "east" => east, "west" => west }
  end

  # @return [Array<Array(Float, Float)>] simplified [lat, lon] pairs of the route
  def route_preview
    RouteSimplifier.new(data_frame[:lat].to_a.zip(data_frame[:lon].to_a)).simplify
  end

  private

  def on_foil = data_frame.where(data_frame[:on_foil].eq(1))

  # @param meters [Numeric] length of the stretch
  # @return [Float, nil] seconds of the fastest stretch, nil when the track is shorter
  def fastest_full_distance(meters)
    dist = data_frame[:distance_cumsum_m].to_a
    times = data_frame[:timestamp].to_a
    min_time = nil
    finish = 0

    # As `start` advances, `finish` only ever moves forward with it, so a
    # single pass with two pointers is enough:
    #
    #   dist  0 ------- 1km ------- 2km ------------->
    #         |start-----------finish|
    #             |start-----------finish|
    #                 |start--------finish|
    dist.each_index do |start|
      finish += 1 while finish < dist.size && dist[finish] <= dist[start] + meters
      break if finish == dist.size

      time_for_distance = times[finish] - times[start]
      min_time = time_for_distance if min_time.nil? || time_for_distance < min_time
    end

    min_time
  end

  ROLLING_SPEED_WINDOW_SEC = 20
  private_constant :ROLLING_SPEED_WINDOW_SEC

  def rolling_speed(df)
    distances = df[:distance_m].to_a
    elapsed = df[:elapsed_sec].to_a
    window_start = 0
    window_m = 0.0
    window_sec = 0.0

    distances.each_index.map do |window_end|
      window_m += distances[window_end]
      window_sec += elapsed[window_end]

      # Drop the oldest segments while the rest still covers the window
      while window_sec - elapsed[window_start] >= ROLLING_SPEED_WINDOW_SEC
        window_m -= distances[window_start]
        window_sec -= elapsed[window_start]
        window_start += 1
      end

      # Until a full window is recorded, pretend the rider stood still before
      # the recording began, so early speeds are only ever underestimated
      window_m / [ window_sec, ROLLING_SPEED_WINDOW_SEC ].max
    end
  end

  # @return [Array<Hash>] Coordinates with timestamp and heart rate data
  def trackpoints
    @trackpoints ||= begin
      gpx = GPX::GPXFile.new(gpx_file:)

      gpx.tracks.flat_map do |track|
        prev_point = track.points.first

        track.points.map do |p|
          distance_m = distance_between(prev_point, p)
          elapsed_sec = p.time - prev_point.time
          prev_point = p

          {
            timestamp: p.time,
            lat: p.lat,
            lon: p.lon,
            hr: p.extensions.xpath("ns3:TrackPointExtension/ns3:hr")&.inner_text&.to_i,
            elapsed_sec:,
            distance_m:,
            speed_m_s: elapsed_sec.positive? ? (distance_m / elapsed_sec.to_f).round(2) : 0.0
          }
        end
      end
    end
  end

  def distance_between(a, b)
    Geocoder::Calculations.distance_between(
      [ a.lat, a.lon ],
      [ b.lat, b.lon ],
      units: :km
    ) * 1_000
  end
end
