module ActivitiesHelper
  KIND_BADGE_VARIANTS = {
    "sup_dw" => "badge-cyan",
    "sup_fwpu" => "badge-sky",
    "dockstart" => "badge-violet",
    "wingfoil" => "badge-teal"
  }.freeze
  private_constant :KIND_BADGE_VARIANTS

  # Renders a coloured pill badge for an activity's kind.
  #
  # @param activity_or_kind [Activity, String, Symbol] an activity, or a raw kind value
  # @return [ActiveSupport::SafeBuffer]
  def kind_badge(activity_or_kind)
    kind = activity_or_kind.respond_to?(:kind) ? activity_or_kind.kind : activity_or_kind.to_s
    variant = KIND_BADGE_VARIANTS.fetch(kind, "badge-slate")
    label = Activity.human_attribute_name("kind.#{kind}")

    content_tag(:span, label, class: variant)
  end

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

  # Splits a formatted distance into its numeric value and unit, so the UI
  # can style them separately.
  #
  # @param distance [Numeric] distance in meters
  # @return [Array(String, String)] e.g. ["12.4", "km"]
  def distance_parts(distance, units: { unit: "m", thousand: "km" })
    split_value_and_unit(number_to_distance(distance, units:))
  end

  # Splits a formatted speed into its numeric value and unit.
  #
  # @param speed [Numeric] speed in km/h
  # @return [Array(String, String)] e.g. ["15.3", "km/h"]
  def speed_parts(speed)
    split_value_and_unit(number_to_speed(speed))
  end

  # Splits a duration into its formatted value; durations have no separate
  # unit, so the second element is always nil.
  #
  # @param duration [Numeric] duration in seconds
  # @return [Array(String, nil)] e.g. ["01:23:45", nil]
  def duration_parts(duration)
    [ number_to_duration(duration), nil ]
  end

  private

  def split_value_and_unit(formatted)
    value, unit = formatted.split(" ", 2)
    [ value, unit ]
  end
end
