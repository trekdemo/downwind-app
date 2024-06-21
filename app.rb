# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'sinatra/reloader'
require 'daru/view'
require_relative 'foil_analyzer'

get '/activities' do
  files = Dir.glob('activities/*.gpx')
  activities = files.map { |file| FoilAnalyzer.new(file, 12) }

  erb :index, locals: { activities: }
end

get '/activities/:file_name/:lift_speed?' do |_file_name, _lift_speed = 12|
  file = "activities/#{params[:file_name]}.gpx"
  @lift_speed = params[:lift_speed].to_i
  @fa = FoilAnalyzer.new(file, @lift_speed)
  df = @fa.data_frame
  # https://api.highcharts.com/highcharts/xAxis
  dist = df[:distance_cumsum_km]
  speed = df[:speed]
  # line = speed.rolling_mean
  @line = df[:on_foil]
  @line_graph = Daru::View::Plot.new(
    [
      { type: :area, name: 'On foil', data: dist.to_a.zip((@line * speed.max).to_a) },
      { type: :line, name: 'Speed', data: dist.to_a.zip(speed.to_a) }
      # { type: :line, name: 'Speed AVG', data: dist.to_a.zip(speed.rolling_mean(5).to_a) }
    ],
    adapter: :highcharts
  )

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
<body>
<div class="container mx-auto"><%= yield %></div></body>
</html>

@@ index
<h1 class="mt-2 mb-4 text-2xl font-bold">Activities</h1>

<table>
  <tr>
    <th>Activity</td>
    <th>Paddle ups</td>
    <th>Distance on foil</td>
  </tr>
  <% activities.each do |activity| %>
  <tr>
    <td><a class="underline text-sky-800" href="/activities/<%= File.basename(activity.file, '.gpx') %>/12"><%= activity.file %></td>
    <td class="text-left"><%= activity.paddle_ups %></td>
    <td class="text-left"><%= activity.distance_on_foil.round(2) %>km</td>
  </tr>
  <% end %>
</table>

@@ show
<div class="my-4">
  <a class="py-2 px-4 bg-sky-100 text-sky-800 rounded" href="/activities">All Activities</a>
</div>

<h1 class="mt-2 mb-4 text-2xl font-bold"><%= params[:file_name] %></h1>

<%= @line_graph.init_script %>
<%= @line_graph.div %>

<pre>Lift Speed = <%= @lift_speed %>km/h</pre>
<pre>Paddle ups = <%= @fa.paddle_ups %></pre>

<pre>Speed (avg) = <%= @fa.avg_speed.round(2) %>km/h</pre>
<pre>Speed (max) = <%= @fa.max_speed.round(2) %>km/h</pre>

<pre>Duration = <%= @fa.duration.to_i %> sec</pre>
<pre>Time on foil = <%= @fa.time_on_foil.round(2) %>sec</pre>
<pre>Time on foil = <%= @fa.time_on_foil_percentage.round(0) %>%</pre>

<pre>Total Distance = <%= @fa.total_distance.round(2) %>km</pre>
<pre>Distance on foil = <%= @fa.distance_on_foil.round(2) %>km</pre>
<pre>Distance on foil = <%= @fa.distance_on_foil_percentage.round(0) %>%</pre>


