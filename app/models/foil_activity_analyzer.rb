# frozen_string_literal: true

# The daru gem has a bunch of warnings that are not relevant to this project.
original_verbosity = $VERBOSE
$VERBOSE = nil
require 'daru'
$VERBOSE = original_verbosity
require 'gpx'
require 'geocoder'

class FoilActivityAnalyzer
  attr_reader :gpx_file, :lift_speed, :data_frame

  def initialize(gpx_file, lift_speed)
    @gpx_file = gpx_file
    @lift_speed = lift_speed
    @data_frame = Daru::DataFrame.new(trackpoints).tap do |df|
      df[:distance_cumsum_m] = df[:distance_m].cumsum

      # On foil when the average speed is above the lift speed for T seconds
      # TODO: Is there a way to specify time instead of N number of points?
      loopback = (20 / df[:ellapsed_sec].mean).to_i
      df[:on_foil] = df[:speed_m_s].rolling_mean(loopback).replace_nils(0).dichotomize(lift_speed / 3.6)
    end
  end

  # - [x] Time on foil

  # - [x] Starts
  # - [ ] Max distance per start (m)

  # - [x] Distance (m)
  # - [x] Distance on foil %
  # - [x] Distance on foil (m)
  # - [ ] Distance per start (m)
  # - [ ] Cumulative distance on foil (km)
  # - [ ] Cumulative distance off foil (km)

  # - [x] Average speed (km/h)
  # - [ ] fastest_kilometer_full_km
  # - [ ] slowest_kilometer_full_km

  def duration = data_frame[:timestamp].range
  def total_distance = data_frame[:distance_cumsum_m].max

  def starts = data_frame[:on_foil].diff.count(1)

  def speed_avg = data_frame[:speed_m_s].mean
  def speed_max = data_frame[:speed_m_s].max

  def hr_avg = data_frame[:hr].mean
  def hr_max = data_frame[:hr].max

  # On foil stats
  def time_on_foil                = on_foil[:ellapsed_sec].sum || 0
  def time_on_foil_percentage     = time_on_foil / duration * 100
  def distance_on_foil            = on_foil[:distance_m].sum || 0
  def distance_on_foil_percentage = distance_on_foil / total_distance * 100
  def speed_avg_on_foil = on_foil[:speed_m_s].mean

  private

  def on_foil = data_frame.where(data_frame[:on_foil].eq(1))

  # @return [Array<Hash>] Coordinates with timestamp and heart rate data
  def trackpoints
    @trackpoints ||= begin
      gpx = GPX::GPXFile.new(gpx_file:)

      gpx.tracks.flat_map do |track|
        prev_point = track.points.first

        track.points.map do |p|
          distance_m = distance_between(prev_point.lat, prev_point.lon, p.lat, p.lon)
          ellapsed_sec = p.time - prev_point.time
          prev_point = p

          {
            timestamp: p.time,
            lat: p.lat,
            lon: p.lon,
            hr: p.extensions.xpath('ns3:TrackPointExtension/ns3:hr')&.inner_text&.to_i,
            ellapsed_sec:,
            distance_m:,
            speed_m_s: ellapsed_sec.positive? ? (distance_m / ellapsed_sec.to_f).round(2) : 0.0
          }
        end
      end
    end
  end

  def distance_between(a_lat, a_lon, b_lat, b_lon)
    Geocoder::Calculations.distance_between(
      [a_lat, a_lon],
      [b_lat, b_lon],
      units: :km
    ) * 1_000
  end
end
