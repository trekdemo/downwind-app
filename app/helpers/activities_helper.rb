module ActivitiesHelper
  def number_to_distance(distance, units: { unit: "m", thousand: "km" })
    number_to_human(distance, units:)
  end

  def number_to_speed(distance)
    number_to_human(distance, precision: 1, significant: false, units: { unit: "km/h" })
  end

  def number_to_duration(duration)
    ActiveSupport::Duration
      .build(duration)
      .parts.values_at(:hours, :minutes, :seconds).compact
      .map { |n| format("%0.2d", n) }
      .join(":")
  end
end
