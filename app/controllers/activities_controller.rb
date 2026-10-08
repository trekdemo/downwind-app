class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[show edit update destroy]

  def index
    @kind = params[:kind].presence_in(Activity.kinds.keys)
    @activities = current_user.activities.with_analysis.of_kind(@kind).order(started_at: :desc)
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

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def activity_params
    params.require(:activity).permit(:lift_speed_kmh, :gpx_file, :kind)
  end
end
