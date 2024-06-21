# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'sinatra/reloader'
require 'daru/view'
require_relative 'foil_analyzer'

get '/' do
  files = Dir.glob('activities/*.gpx')
  activities = files.map { |file| FoilAnalyzer.new(file, 12) }

  erb :speed, locals: { activities: }
end

# TODO:
# - [ ] Ensure that the visualization is using the distance as the X-axis
# - [ ] Detect when on foil
# - [ ] Count paddle ups

get '/activities/:file_name' do
  file = "activities/#{params[:file_name]}.gpx"
  df = FoilAnalyzer.new(file, 12).data_frame
  @line_graph = Daru::View::Plot.new([], { adapter: :highcharts })
  # @line_graph = Daru::View::Plot.new(df, type: :line, x: :distance_km, y: :speed)
  @line_graph.add_series(name: 'Speed', data: df[:speed])
  @line_graph.add_series(name: 'Rolling Mean', data: df[:speed_avg])

  erb :show
end

__END__

@@ layout
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Speed</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body><%= yield %></body>
</html>

@@ show
<%= @line_graph.init_script %>
<%= @line_graph.div %>
