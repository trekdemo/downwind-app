# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'sinatra/reloader'
require 'gpx'
require 'geocoder'
require_relative 'speed'

get '/' do
  speeds = Speed.new('./activity_15920387501.gpx').speeds
  averages = speeds.each_cons(5).map do |speeds|
    {
      time: speeds.last[:time],
      distance_km: speeds.last[:distance_km],
      cum_distance_km: speeds.last[:cum_distance_km],
      speed: speeds.sum { |speed| speed[:speed] } / 4
    }
  end
  total_distance = speeds.last[:cum_distance_km]
  on_foil_distance = speeds
                     .select { |speed| speed[:speed] > 12 }
                     .sum { |speed| speed[:distance_km] }

  erb :speed, locals: {
    speeds:,
    averages:,
    on_foil_distance:,
    total_distance:
  }
end
