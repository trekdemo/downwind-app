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
        distance_km = Geocoder::Calculations.distance_between([a.lat, a.lon], [b.lat, b.lon], units: :km).round(4)
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
    Daru::DataFrame.new(points).tap do |df|
      df[:distance_cumsum_km] = df[:distance_km].cumsum
      df[:on_foil] = df[:speed].rolling_mean(15).replace_nils(0).dichotomize(lift_speed)
    end
  end

  def paddle_ups = data_frame[:on_foil].diff.count(1)

  def avg_speed = data_frame[:speed].mean
  def max_speed = data_frame[:speed].max

  def duration = data_frame[:time].range
  def time_on_foil = data_frame.where(data_frame[:on_foil].eq(1))[:time_diff_sec].sum || 0
  def time_on_foil_percentage = time_on_foil / duration * 100

  def total_distance = data_frame[:distance_cumsum_km].max
  def distance_on_foil = data_frame.where(data_frame[:on_foil].eq(1))[:distance_km].sum || 0
  def distance_on_foil_percentage = distance_on_foil / total_distance * 100
end

# Usage
if $PROGRAM_NAME == __FILE__
  # fa = FoilAnalyzer.new('activities/2024-06-17_2.gpx', 12)
  fa = FoilAnalyzer.new('activities/2023-12-28-wing.gpx', 12)
  df = fa.data_frame
  # puts df
end
