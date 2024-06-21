# frozen_string_literal: true

require 'daru'
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

  def points
    @points ||= @gpx.tracks.flat_map do |track|
      track.points.each_cons(2).map do |a, b|
        distance_km = Geocoder::Calculations.distance_between([a.lat, a.lon], [b.lat, b.lon], units: :km)
        time_diff_sec = b.time - a.time

        {
          time: b.time,
          time_diff_sec:,
          distance_km:,
          speed: (distance_km / time_diff_sec.to_f * 3_600).round(2),
          hr: b.extensions.xpath('ns3:TrackPointExtension/ns3:hr')&.inner_text&.to_i
        }
      end
    end
  end

  def data_frame
    index = Daru::DateTimeIndex.new(points.map { |point| point[:time] })
    Daru::DataFrame.new(points, index:).tap do |df|
      df.delete_vector(:time)
      df[:speed_avg] = df[:speed].rolling_mean(10)
    end
  end

  def total_distance = data_frame[:distance_km].sum
end

# Usage
if $PROGRAM_NAME == __FILE__
  fa = FoilAnalyzer.new('activities/2024-06-17_2.gpx', 12)
  fa = FoilAnalyzer.new('activities/2023-12-28-wing.gpx', 12)
  df = fa.data_frame
end
