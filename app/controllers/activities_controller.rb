class ActivitiesController < ApplicationController
  before_action :require_login
  before_action :set_activity, only: %i[show edit update destroy]

  def index
    @activities = current_user.activities.with_analysis.order(started_at: :desc)
    @activity_kind_counts = Activity.group(:kind).count
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
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity, notice: "Activity was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
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
