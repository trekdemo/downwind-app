# frozen_string_literal: true

# The daru gem has a bunch of warnings that are not relevant to this project.
original_verbosity = $VERBOSE
$VERBOSE = nil
require 'daru'
$VERBOSE = original_verbosity
require_relative 'activity'

# # Usage
#
#   activity = Activity.from_gpx('activities/2023-12-28-wing.gpx')
#   fa = FoilAnalyzer.new(activity, 12)
#   df = fa.data_frame
class FoilActivityAnalyzer
  attr_reader :activity, :lift_speed, :file, :data_frame

  def initialize(gpx_file, lift_speed)
    @file = gpx_file
    @activity = Activity.from_gpx(gpx_file)
    @lift_speed = lift_speed
    @data_frame = Daru::DataFrame.new(activity.trackpoints).tap do |df|
      df[:distance_cumsum_m] = df[:distance_m].cumsum

      # On foil when the average speed is above the lift speed for T seconds
      # TODO: Is there a way to specify time instead of N number of points?
      loopback = (20 / df[:ellapsed_sec].mean).to_i
      df[:on_foil] = df[:speed_m_s].rolling_mean(loopback).replace_nils(0).dichotomize(lift_speed / 3.6)
    end
  end

  def duration = data_frame[:timestamp].range
  def total_distance = data_frame[:distance_cumsum_m].max

  def paddle_ups = data_frame[:on_foil].diff.count(1)

  def speed_avg = data_frame[:speed_m_s].mean
  def speed_max = data_frame[:speed_m_s].max

  # On foil stats
  def time_on_foil                = on_foil[:ellapsed_sec].sum || 0
  def time_on_foil_percentage     = time_on_foil / duration * 100
  def distance_on_foil            = on_foil[:distance_m].sum || 0
  def distance_on_foil_percentage = distance_on_foil / total_distance * 100

  private

  def on_foil = data_frame.where(data_frame[:on_foil].eq(1))
end
