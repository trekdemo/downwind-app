class DashboardController < ApplicationController
  def index
    @kind = params[:kind].presence_in(Activity.kinds.keys)
    @activities = current_user.activities.with_analysis.of_kind(@kind).order(started_at: :desc)

    chart_activities = @activities.select(&:analyzed?).sort_by(&:started_at)
    @chart_data = {
      labels: chart_labels_for(chart_activities),
      datasets: [
        {
          label: "% on foil",
          data: chart_activities.map { |activity| activity.analysis.distance_on_foil_percentage || 0 },
          borderColor: "var(--color-accent)",
          backgroundColor: "color-mix(in oklab, var(--color-accent) 15%, transparent)",
          borderWidth: 2,
          pointStyle: false,
          type: "line",
          fill: true,
          tension: 0.3,
          suffix: "%",
          yAxisID: "y"
        },
        {
          label: "Paddle-ups",
          data: chart_activities.map { |activity| activity.analysis.starts || 0 },
          backgroundColor: "var(--color-chart-series-secondary)",
          borderWidth: 0,
          borderRadius: 4,
          barPercentage: 0.5,
          type: "bar",
          yAxisID: "y2"
        }
      ]
    }
  end

  private

  # Builds unique, unambiguous chart labels: the year is added when the
  # activities span more than one year, and the time is added when several
  # activities fall on the same date (otherwise same-day sessions would share
  # a label, e.g. two sessions both showing "Sep 20").
  def chart_labels_for(activities)
    date_format = activities.map { |activity| activity.started_at.year }.uniq.size > 1 ? "%b %-d, %Y" : "%b %-d"
    activities_per_date = activities.group_by { |activity| activity.started_at.to_date }

    activities.map do |activity|
      label = l(activity.started_at, format: date_format)
      if activities_per_date[activity.started_at.to_date].size > 1
        "#{label} #{l(activity.started_at, format: '%H:%M')}"
      else
        label
      end
    end
  end
end
