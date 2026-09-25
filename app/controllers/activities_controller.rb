class ActivitiesController < ApplicationController
  before_action :require_login
  before_action :set_activity, only: %i[show edit update destroy]

  def index
    @kind = params[:kind].presence_in(Activity.kinds.keys)
    @activities = current_user.activities.with_analysis.order(started_at: :desc)
    @activities = @activities.where(kind: @kind) if @kind
    on_foil = @activities.map do |activity|
       activity.analysis.distance_on_foil_percentage
    end
    starts = @activities.map do |activity|
      activity.analysis.starts
    end
    @chart_data = {
      labels: @activities.count.times.to_a,
      datasets: [
        {
          label: "% on foil",
          data: on_foil.reverse,
          borderWidth: 8,
          pointStyle: false,
          type: "line",
          tension: 0.3,
          suffix: "%"
        },
        {
          label: "# of starts",
          data: starts.reverse,
          borderWidth: 1,
          barPercentage: 0.3,
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
    @activity = current_user.activities.create(activity_params)

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

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def activity_params
    params.require(:activity).permit(:lift_speed_kmh, :gpx_file, :kind)
  end
end
