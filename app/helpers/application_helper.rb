module ApplicationHelper
  # Returns a nested array that can be used as the collection for a select field
  #
  # @param model_class [Class] model class containing with the enum
  # @param enum [Symbol,String] name of the enum
  def options_for_enum(model_class, enum)
    enum_hash = model_class.send(enum.to_s.pluralize)

    enum_hash.map do |key, _value|
      [ model_class.human_attribute_name("#{enum}.#{key}"), key ]
    end
  end

  # Heroicons-outline-style (24x24, stroke-width 1.5) inline SVG icons.
  #
  # @param name [Symbol,String] icon name, see ICONS keys
  # @param class [String] CSS classes for the <svg>, defaults to "size-5"
  # @return [ActiveSupport::SafeBuffer]
  # @raise [ArgumentError] if the icon name is unknown
  ICONS = {
    wave: "M2.25 15.75c1.5-1.5 3-1.5 4.5 0s3 1.5 4.5 0 3-1.5 4.5 0 3 1.5 4.5 0M2.25 10.5c1.5-1.5 3-1.5 4.5 0s3 1.5 4.5 0 3-1.5 4.5 0 3 1.5 4.5 0",
    "chart-bar": "M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z",
    list: "M8.25 6.75h12M8.25 12h12M8.25 17.25h12M3.75 6.75h.007v.008H3.75V6.75Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0ZM3.75 12h.007v.008H3.75V12Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm-.375 5.25h.007v.008H3.75v-.008Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z",
    upload: "M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 7.5 12 3m0 0L7.5 7.5M12 3v13.5",
    plus: "M12 4.5v15m7.5-7.5h-15",
    "arrow-left": "M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18",
    pencil: "m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125",
    trash: "M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0",
    clock: "M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z",
    "map-pin": "M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z",
    bolt: "M3.75 13.5 10.5 3v7.5h9.75L10.5 21v-7.5H3.75Z",
    heart: "M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z",
    flag: "M3 3v18M3 4.5h13.5l-1.5 3 1.5 3H3",
    "arrows-right-left": "M7.5 21 3 16.5m0 0L7.5 12M3 16.5h18M16.5 3 21 7.5m0 0L16.5 12M21 7.5H3",
    ruler: "M4.5 4.5 19.5 19.5m0 0-3 0m3 0 0-3M4.5 4.5l0 3m0-3 3 0M9 15l-1.5 1.5M12 12l-1.5 1.5M15 9l-1.5 1.5",
    calendar: "M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5",
    user: "M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z",
    logout: "M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75",
    check: "M4.5 12.75l6 6 9-13.5",
    x: "M6 18 18 6M6 6l12 12",
    trophy: "M16.5 18.75h-9m9 0a3 3 0 0 0 3-3v-.15c0-.51-.163-1.007-.465-1.42L18 12h-12l-1.035 2.18A2.652 2.652 0 0 0 4.5 15.6v.15a3 3 0 0 0 3 3m9 0v2.25m-9-2.25v2.25m3-15.75h3M6.75 5.106a24.255 24.255 0 0 1-.665-4.052A.75.75 0 0 1 6.837.75h10.326a.75.75 0 0 1 .752.304 24.255 24.255 0 0 1-.665 4.052M6.75 5.106c-1.665.34-3.264.81-4.79 1.395M6.75 5.106c1.941.398 3.976.61 6.075.61s4.134-.212 6.075-.61m0 0c1.526.585 3.125 1.055 4.79 1.395M18 12l1.035 2.18",
    "chevron-down": "m19.5 8.25-7.5 7.5-7.5-7.5"
  }.freeze
  private_constant :ICONS

  def icon(name, class: "size-5")
    css_class = binding.local_variable_get(:class)
    path_data = ICONS.fetch(name.to_sym) do
      raise ArgumentError, "Unknown icon: #{name.inspect}"
    end

    content_tag(:svg,
      content_tag(:path, nil, "stroke-linecap": "round", "stroke-linejoin": "round", d: path_data),
      class: css_class,
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      "stroke-width": "1.5",
      stroke: "currentColor",
      "aria-hidden": "true")
  end
end
