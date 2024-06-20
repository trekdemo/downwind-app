# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'sinatra/reloader'
require_relative 'foil_analyzer'

get '/' do
  files = Dir.glob('activities/*.gpx')
  activities = files.map { |file| FoilAnalyzer.new(file, 12) }

  erb :speed, locals: { activities: }
end
