# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'sinatra/reloader'
require 'daru/view'
require_relative 'foil_activity_analyzer'

before(%r{/(.+)/\$}) { |path| redirect(path, 301) }

get '/activities' do
  files = Dir.glob('activities/*.gpx')
  analyses = files.map { |file| FoilActivityAnalyzer.new(file, 12) }

  erb :index, locals: { analyses: }
end

get '/activities/:file_name(/:lift_speed)?' do
  file = "activities/#{params[:file_name]}.gpx"
  @lift_speed = (params[:lift_speed] || 12).to_i
  @fa = FoilActivityAnalyzer.new(file, @lift_speed)
  df = @fa.data_frame
  dist = df[:distance_cumsum_m]
  speed = df[:speed_m_s] * 3.6
  # line = speed.rolling_mean
  on_foil = df[:on_foil]
  @line_graph = Daru::View::Plot.new(
    [
      { type: :area, name: 'On foil', data: dist.to_a.zip((on_foil * speed.max).to_a), showInLegend: false },
      { type: :line, name: 'Speed', data: dist.to_a.zip(speed.to_a) }
      # { type: :line, name: 'HR', data: dist.to_a.zip(df[:hr].to_a) }
      # { type: :line, name: 'Speed AVG', data: dist.to_a.zip(speed.rolling_mean(5).to_a) }
    ],
    title: { text: nil },
    xAxis: [{ title: { text: 'Distance (m)' } }],
    yAxis: [{ title: { text: 'Speed (km/h)' } }],
    tooltip: { enabled: false },
    legend: { enabled: false },
    adapter: :highcharts
  )

  erb :show
end
