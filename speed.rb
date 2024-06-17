require 'gpx'
require 'geocoder'
# Parse the GPX file
gpx = GPX::GPXFile.new(gpx_file: './activity_15920387501.gpx')

# Extract speed information

points = gpx.tracks[0].points
speeds = points.each_cons(2).map do |previous_trkpt, trkpt|
  # Calculate speed in km/h
  distance_m = Geocoder::Calculations.distance_between(previous_trkpt.lat, previous_trkpt.lon, trkpt.lat, trkpt.lon)
  time_difference_min = trkpt.time - previous_trkpt.time

  # Calculate speed in km/h
  (distance_m * 1_000) / (time_difference_min.to_f * 3_600)
end

# Print the speeds
puts 'Speeds (km/h):'
puts speeds
