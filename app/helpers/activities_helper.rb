module ActivitiesHelper
  KIND_BADGE_VARIANTS = {
    "sup_dw" => "badge-sup-dw",
    "sup_fwpu" => "badge-sup-fwpu",
    "dockstart" => "badge-dockstart",
    "wingfoil" => "badge-wingfoil"
  }.freeze
  private_constant :KIND_BADGE_VARIANTS

  # Renders a coloured pill badge for an activity's kind.
  #
  # @param activity_or_kind [Activity, String, Symbol] an activity, or a raw kind value
  # @return [ActiveSupport::SafeBuffer]
  def kind_badge(activity_or_kind)
    kind = activity_or_kind.respond_to?(:kind) ? activity_or_kind.kind : activity_or_kind.to_s
    variant = KIND_BADGE_VARIANTS.fetch(kind)
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
    total_seconds = duration.round
    hours, remainder = total_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)

    format("%d:%02d:%02d", hours, minutes, seconds)
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

  # Draws a simplified route as a single-colour outline, north up.
  # The longest side spans 100 units of the viewBox; size it with CSS.
  #
  # @param points [Array<Array(Float, Float)>, nil] [lat, lon] pairs, e.g. Analysis#route_preview
  # @param options [Hash] extra attributes for the <svg> tag, e.g. class
  # @return [ActiveSupport::SafeBuffer, nil] nil when there is nothing to draw
  def route_preview_svg(points, **options)
    return if points.blank?

    # Same equirectangular projection as RouteSimplifier; SVG's y axis points down
    lats = points.map(&:first)
    scale = Math.cos((lats.min + lats.max) / 2.0 * Math::PI / 180)
    projected = points.map { |lat, lon| [ lon * scale, -lat ] }

    (min_x, max_x), (min_y, max_y) = projected.transpose.map(&:minmax)
    width = max_x - min_x
    height = max_y - min_y
    return if [ width, height ].max.zero?

    factor = 100 / [ width, height ].max
    polyline_points = projected.map do |x, y|
      "#{((x - min_x) * factor).round(1)},#{((y - min_y) * factor).round(1)}"
    end

    tag.svg(
      tag.polyline(
        points: polyline_points.join(" "),
        fill: "none",
        stroke: "currentColor",
        "stroke-width": 2,
        "stroke-linecap": "round",
        "stroke-linejoin": "round",
        "vector-effect": "non-scaling-stroke"
      ),
      # Padding keeps the rounded line caps inside the box
      id: dom_target(:route_preview_svg),
      viewBox: "-2 -2 #{(width * factor + 4).round(1)} #{(height * factor + 4).round(1)}",
      preserveAspectRatio: "xMidYMid meet",
      aria: { hidden: true },
      **options
    )
  end

  private

  def split_value_and_unit(formatted)
    value, unit = formatted.split(" ", 2)
    [ value, unit ]
  end
end
