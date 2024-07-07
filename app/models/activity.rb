# frozen_string_literal: true

require 'gpx'
require 'geocoder'

# Activity represents an activity and its trackpoints. Trackpoints represent a
# coordinates in time with heart rate information.
class Activity < ApplicationRecord
  has_one_attached :gpx_file

  def self.create_from_gpx(gpx_file, lift_speed)
    gpx = GPX::GPXFile.new(gpx_file:)
    track = gpx.tracks[0]
    started_at = track&.points&.first&.time || Time.current

    create(title: track.name, lift_speed_kmh: lift_speed, gpx_file:, started_at:)
  end

  def analysis
    @analysis ||= FoilActivityAnalyzer.new(trackpoints, lift_speed_kmh)
  end

  # @return [Array<Hash>] Coordinates with timestamp and heart rate data
  def trackpoints
    @trackpoints ||= begin
      gpx = gpx_file.open do |file|
        GPX::GPXFile.new(gpx_file: file)
      end

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
