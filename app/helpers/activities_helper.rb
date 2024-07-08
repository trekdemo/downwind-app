module ActivitiesHelper
  def number_to_distance(distance)
    number_to_human(distance, units: { unit: 'm', thousand: 'km' })
  end

  def number_to_speed(distance)
    number_to_human(distance, precision: 1, significant: false, units: { unit: 'km/h' })
  end

  def number_to_duration(duration)
    ActiveSupport::Duration
      .build(duration)
      .parts.values_at(:hours, :minutes, :seconds).compact
      .map { |n| format('%0.2d', n) }
      .join(':')
  end

  def speed_chart(activity)
    df = activity.analysis.data_frame
    dist = df[:distance_cumsum_m]
    speed = df[:speed_m_s].rolling_mean * 3.6
    # line = speed.rolling_mean
    on_foil = df[:on_foil]

    line_chart(
      [
        # { name: 'On foil', data: dist.to_a.zip((on_foil * speed.max).to_a) },
        { name: 'Speed', data: dist.to_a.zip(speed.to_a) }
        # { type: :line, name: 'HR', data: dist.to_a.zip(df[:hr].to_a) }
        # { type: :line, name: 'Speed AVG', data: dist.to_a.zip(speed.rolling_mean(5).to_a) }
      ],
      # title: 'Speed'
      # xtitle: 'Distance (m)',
      # ytitle: 'Speed (km/h)',
      # width: '100%'
      points: false,
      legend: false,
      suffix: 'km/h',
      round: 1,
      library: { options: { elements: { line: { borderWidth: 1 } } } },
      code: true
    )
  end
end
