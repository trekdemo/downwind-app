# frozen_string_literal: true

require 'gpx'
require 'geocoder'

# Activity represents an activity and its trackpoints. Trackpoints represent a
# coordinates in time with heart rate information.
class Activity
  attr_reader :title, :start_time
  # @return [Array<Hash>] Coordinates with timestamp and heart rate data
  attr_reader :trackpoints

  TrackPoint = Data.define(:timestamp, :ellapsed_sec, :distance_m, :speed_m_s, :hr, :lat, :lon)

  def initialize(title:, trackpoints: [])
    @title = title
    @trackpoints = trackpoints
    @start_time = trackpoints.first[:timestamp]
  end

  def self.from_gpx(file)
    gpx = GPX::GPXFile.new(gpx_file: file)
    track = gpx.tracks[0]

    title = track.name
    points = gpx.tracks.flat_map do |track|
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
          speed_m_s: ellapsed_sec > 0 ? (distance_m / ellapsed_sec.to_f).round(2) : 0.0
        }
      end
    end

    new(title:, trackpoints: points)
  end

  def self.distance_between(a_lat, a_lon, b_lat, b_lon)
    Geocoder::Calculations.distance_between(
      [a_lat, a_lon],
      [b_lat, b_lon],
      units: :km
    ) * 1_000
  end
  private_class_method :distance_between
end
