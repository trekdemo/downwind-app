class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[show edit update destroy]

  def index
    @activities = Activity.order(started_at: :desc)
  end

  def show
    @fa = @activity.analysis
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
  end

  def new
    @activity = Activity.new
  end

  def edit; end

  def create
    @activity = Activity.create_from_gpx(activity_params[:gpx_file], activity_params[:lift_speed])

    if @activity.save
      redirect_to @activity, notice: 'Activity was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity, notice: 'Activity was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy!
    redirect_to activities_url, notice: 'Activity was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def activity_params
    params.require(:activity).permit(:lift_speed, :gpx_file)
  end
end
