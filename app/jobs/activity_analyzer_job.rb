class ActivityAnalyzerJob < ApplicationJob
  queue_as :default

  def perform(activity)
    activity.analyze_gpx_file!
  end
end
