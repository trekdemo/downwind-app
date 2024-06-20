# frozen_string_literal: true

require 'gpx'
require 'geocoder'

# The speeds variable now contains the speed information for the GPX file
class FoilAnalyzer
  attr_reader :file, :lift_speed

  def initialize(gpx_file, lift_speed)
    @file = gpx_file
    @lift_speed = lift_speed
    @gpx = GPX::GPXFile.new(gpx_file:)
  end

  def total_distance = speeds.last[:cum_distance_km]

  def on_foil_distance = averages
    .select { |speed| speed[:speed] >= @lift_speed }
    .sum { |speed| speed[:distance_km] }

  def averages(tail = 5)
    speeds.each_cons(tail).map do |speeds|
      {
        time: speeds.last[:time],
        distance_km: speeds.last[:distance_km],
        cum_distance_km: speeds.last[:cum_distance_km],
        speed: speeds.sum { |speed| speed[:speed] } / 5
      }
    end
  end

  def speeds
    total_dist_km = 0
    points = @gpx.tracks[0].points
    points.each_cons(2).map do |a, b|
      # Calculate speed in km/h
      distance_km = Geocoder::Calculations.distance_between([a.lat, a.lon], [b.lat, b.lon], units: :km)
      time_difference_sec = b.time - a.time

      {
        time: b.time.iso8601,
        distance_km:,
        cum_distance_km: total_dist_km += distance_km,
        speed: (distance_km / time_difference_sec.to_f * 3_600).round(2),
        hr: b.extensions.xpath('ns3:TrackPointExtension/ns3:hr')&.inner_text&.to_i
      }
    end
  end
end

# Usage
if $PROGRAM_NAME == __FILE__
  speed = FoilAnalyzer.new('activities/2024-06-17_2.gpx', 12)
  puts speed.speeds
end
