class DashboardController < ApplicationController
  HEATMAP_PERIOD = 3.months
  # Accent strength per intensity level, from the lightest to the busiest day
  HEATMAP_LEVELS = [ 30, 55, 80, 100 ].freeze

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

    @heatmap_data = heatmap_data_for(@activities.select(&:analyzed?))
  end

  private

  # One cell per day for the past HEATMAP_PERIOD, laid out like a calendar:
  # a column per week (labelled with its Monday) and a row per weekday. A
  # cell's shade is the day's total session time relative to the busiest day.
  def heatmap_data_for(activities)
    days = HEATMAP_PERIOD.ago.to_date.beginning_of_week..Date.current
    seconds_per_day = activities
      .group_by { |activity| activity.started_at.to_date }
      .transform_values { |same_day| same_day.sum { |activity| activity.analysis.duration } }
    busiest_day_seconds = seconds_per_day.values_at(*days).compact.max

    cells = days.map do |day|
      seconds = seconds_per_day.fetch(day, 0)
      {
        x: l(day.beginning_of_week, format: "%b %-d"),
        y: l(day, format: "%a"),
        title: l(day, format: "%a, %b %-d"),
        label: seconds.positive? ? helpers.number_to_duration(seconds) : "No sessions"
      }
    end

    {
      xLabels: days.step(7).map { |monday| l(monday, format: "%b %-d") },
      yLabels: days.first(7).map { |day| l(day, format: "%a") },
      datasets: [
        {
          label: "Time on the water",
          data: cells,
          backgroundColor: days.map { |day| heatmap_color(seconds_per_day.fetch(day, 0), busiest_day_seconds) },
          borderWidth: 0,
          borderRadius: 3
        }
      ]
    }
  end

  def heatmap_color(seconds, busiest_day_seconds)
    return "var(--color-line-subtle)" unless seconds.positive?

    level = (HEATMAP_LEVELS.size * seconds / busiest_day_seconds).ceil
    "color-mix(in oklab, var(--color-accent) #{HEATMAP_LEVELS[level - 1]}%, transparent)"
  end

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
