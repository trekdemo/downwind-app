# frozen_string_literal: true

require 'gpx'
require 'geocoder'
require 'moving_average'

# The speeds variable now contains the speed information for the GPX file
class Speed
  def initialize(gpx_file)
    @gpx = GPX::GPXFile.new(gpx_file:)
  end

  def speeds
    total_dist_km = 0
    points = @gpx.tracks[0].points
    data = points.each_cons(2).map do |a, b|
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
  speed = Speed.new('./activity_15920387501.gpx')
  binding.irb
  puts speed.speeds
end
