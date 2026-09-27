class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[show edit update destroy]

  def index
    @activities = current_user.activities.with_analysis.order(started_at: :desc)
    if @kind = params[:kind].presence_in(Activity.kinds.keys)
      @activities = @activities.where(kind: @kind)
    end

    chart_activities = @activities.select(&:analyzed?).sort_by(&:started_at)
    @chart_data = {
      labels: chart_labels_for(chart_activities),
      datasets: [
        {
          label: "% on foil",
          data: chart_activities.map { |activity| activity.analysis.distance_on_foil_percentage || 0 },
          borderColor: "#22d3ee",
          backgroundColor: "rgba(34, 211, 238, 0.15)",
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
          backgroundColor: "#475569",
          borderWidth: 0,
          borderRadius: 4,
          barPercentage: 0.5,
          type: "bar",
          yAxisID: "y2"
        }
      ]
    }
  end

  def show; end

  def new
    @activity = Activity.new
  end

  def edit; end

  def create
    @activity = current_user.activities.build(activity_params)

    if @activity.save
      redirect_to @activity, notice: "Activity was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity, notice: "Activity was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @activity.destroy!
    redirect_to activities_url, notice: "Activity was successfully destroyed.", status: :see_other
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

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def activity_params
    params.require(:activity).permit(:lift_speed_kmh, :gpx_file, :kind)
  end
end
