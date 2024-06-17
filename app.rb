# frozen_string_literal: true

require 'sinatra'
require 'gpx'
require 'geocoder'

# Parse the GPX file
gpx = GPX::GPXFile.new(gpx_file: './activity_15920387501.gpx')

# Extract speed information
points = gpx.tracks[0].points
speeds = points.each_cons(2).map do |a, b|
  # Calculate speed in km/h
  distance_km = Geocoder::Calculations.distance_between([a.lat, a.lon], [b.lat, b.lon], units: :km)
  time_difference_sec = b.time - a.time

  # Calculate speed in km/h
  (distance_km / time_difference_sec.to_f * 3_600).round(2)
end

get '/' do
  erb :speed, locals: { speeds: }
end
