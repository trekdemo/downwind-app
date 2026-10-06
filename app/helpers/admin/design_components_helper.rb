module Admin::DesignComponentsHelper
  # Every colour role the UI uses, as defined in the semantic @theme block
  # of app/assets/tailwind/application.css. Each role is a `--color-<role>`
  # variable, so it is used as `bg-<role>`, `text-<role>`, `ring-<role>/30`…
  # and read by the chart and map controllers as `var(--color-<role>)`.
  #
  # `swatch` is the full class that paints the role, written out so Tailwind
  # generates it; the CSP blocks inline styles, so a class is the only way.
  COLOR_ROLES = [
    {
      group: "Surfaces",
      colors: [
        { swatch: "bg-canvas", usage: "Page background, sticky header (/80), route preview backdrop (/60), focus-ring offset. Also the theme-color meta tags." },
        { swatch: "bg-raised", usage: "Cards, inputs, inactive filter pills, table head (/50), upload dropzone (/50), map loading overlay (/40), chart tooltip." },
        { swatch: "bg-sunken", usage: "Secondary button, ghost/radio hover, table row hover (/50), avatar, skeleton blocks, progress track, dropzone icon circle." }
      ]
    },
    {
      group: "Lines",
      colors: [
        { swatch: "bg-line-card/5", usage: "Hairline ring around cards (ring-line-card/5)." },
        { swatch: "bg-line-subtle", usage: "Header bottom border, card-header divider, table dividers, inactive filter pill ring, chart grid and tooltip border." },
        { swatch: "bg-line", usage: "Input and radio rings, secondary button ring and hover background, dashed dropzone border, spinner track, badge-neutral background (/40), base border colour." },
        { swatch: "bg-line-strong", usage: "Map spinner track, badge-neutral ring (/40)." }
      ]
    },
    {
      group: "Foreground",
      colors: [
        { swatch: "bg-fg-strong", usage: "Page titles (h1), stat values." },
        { swatch: "bg-fg-emphasis", usage: "Card and section headings, logo, secondary button text, hover text, primary table cell, chart tooltip title." },
        { swatch: "bg-fg", usage: "Body text (on <body>), table cells, dropzone prompt, empty-state heading." },
        { swatch: "bg-fg-secondary", usage: "Form labels, ghost button, badge-neutral, radio option text, avatar initial, chart tooltip body." },
        { swatch: "bg-fg-muted", usage: "Stat/card/table-head labels, units, dates, helper text, inactive nav, chart ticks and legend." },
        { swatch: "bg-fg-placeholder", usage: "Input placeholders." },
        { swatch: "bg-fg-faint", usage: "Empty-state illustration icon, route outline behind the map." },
        { swatch: "bg-on-cta", usage: "Primary button text." },
        { swatch: "bg-on-danger", usage: "Danger button text." }
      ]
    },
    {
      group: "Accent (brand)",
      colors: [
        { swatch: "bg-accent-fg", usage: "Active nav and filter pill, selected radio, chosen file name, link hover." },
        { swatch: "bg-accent", usage: "Icons, links, focus rings, spinner head, title hover, dropzone hover border, route preview (/80), progress chart line and fill (15%)." },
        { swatch: "bg-accent-solid", usage: "Progress bar fill, foiling doughnut. Tinted backgrounds (/10, /5), rings (/30, /40), auth-page radial glow (/10)." }
      ]
    },
    {
      group: "Call to action",
      colors: [
        { swatch: "bg-cta", usage: "Primary button background." },
        { swatch: "bg-cta-hover", usage: "Primary button hover." }
      ]
    },
    {
      group: "Status",
      colors: [
        { swatch: "bg-danger", usage: "Danger button background." },
        { swatch: "bg-danger-hover", usage: "Danger button hover, alert and error tints (/10, /5) and rings (/30)." },
        { swatch: "bg-danger-icon", usage: "Heart-rate card icon." },
        { swatch: "bg-danger-fg", usage: "Alert flash text, form error heading." },
        { swatch: "bg-danger-fg-soft/90", usage: "Form error list items." },
        { swatch: "bg-success", usage: "Notice flash tint (/10) and ring (/30)." },
        { swatch: "bg-success-icon", usage: "Password-reset confirmation check." },
        { swatch: "bg-success-fg", usage: "Notice flash text." },
        { swatch: "bg-pending", usage: "badge-pending tint and ring (\"Analyzing…\")." },
        { swatch: "bg-pending-fg", usage: "badge-pending text." }
      ]
    },
    {
      group: "Activity kinds",
      colors: [
        { swatch: "bg-kind-sup-dw", usage: "badge-sup-dw tint and ring: SUP downwind." },
        { swatch: "bg-kind-sup-dw-fg", usage: "badge-sup-dw text." },
        { swatch: "bg-kind-sup-fwpu", usage: "badge-sup-fwpu tint and ring: SUP flatwater pump-up." },
        { swatch: "bg-kind-sup-fwpu-fg", usage: "badge-sup-fwpu text." },
        { swatch: "bg-kind-dockstart", usage: "badge-dockstart tint and ring: Dockstart." },
        { swatch: "bg-kind-dockstart-fg", usage: "badge-dockstart text." },
        { swatch: "bg-kind-wingfoil", usage: "badge-wingfoil tint and ring: Wingfoil." },
        { swatch: "bg-kind-wingfoil-fg", usage: "badge-wingfoil text." }
      ]
    },
    {
      group: "Data visualisation",
      colors: [
        { swatch: "bg-chart-series-secondary", usage: "Paddle-ups bars in the progress chart (ActivitiesController)." },
        { swatch: "bg-chart-off-foil", usage: "Off-foil slice of the foiling doughnut." },
        { swatch: "bg-speed-slow", usage: "Map hotline and legend gradient start." },
        { swatch: "bg-speed-medium", usage: "Map hotline and legend gradient middle." },
        { swatch: "bg-speed-fast", usage: "Map hotline at 75% only; missing from the legend gradient." },
        { swatch: "bg-speed-max", usage: "Map hotline and legend gradient end." }
      ]
    }
  ].freeze

  # @param color [Hash] an entry of COLOR_ROLES
  # @return [String] the role's name, e.g. "line-card" for "bg-line-card/5"
  def swatch_role(color)
    color[:swatch].delete_prefix("bg-").split("/").first
  end

  # @param color [Hash] an entry of COLOR_ROLES
  # @return [String] e.g. "--color-raised" or "--color-line-card/5"
  def swatch_label(color)
    "--color-#{color[:swatch].delete_prefix("bg-")}"
  end

  # Renders a component example with its name, where it is defined, and
  # the HTML it produces, so the markup can be copied.
  #
  # @param name [String]
  # @param source [String] the file or helper that defines the component
  # @return [ActiveSupport::SafeBuffer]
  def design_example(name, source:, &block)
    rendered = capture(&block)

    tag.div(class: "space-y-3") do
      safe_join([
        tag.div(class: "flex flex-wrap items-baseline justify-between gap-2") do
          tag.h3(name, class: "text-sm font-semibold text-fg-emphasis") +
            tag.code(source, class: "text-xs text-fg-placeholder")
        end,
        tag.div(rendered, class: "rounded-lg bg-canvas/60 p-4 ring-1 ring-inset ring-line-subtle"),
        tag.details(class: "group text-xs") do
          tag.summary("HTML", class: "cursor-pointer text-fg-muted hover:text-fg") +
            tag.pre(tag.code(rendered.to_str.strip), class: "mt-2 max-h-64 overflow-auto rounded-lg bg-canvas p-3 text-fg-secondary ring-1 ring-inset ring-line-subtle")
        end
      ])
    end
  end

  # A wobbly closed loop, standing in for Analysis#route_preview.
  #
  # @return [Array<Array(Float, Float)>] [lat, lon] pairs
  def sample_route_preview
    (0..48).map do |step|
      angle = step * 2 * Math::PI / 48
      radius = 0.01 * (1 + 0.25 * Math.sin(3 * angle))
      [ 47.0 + radius * Math.sin(angle), 19.0 + radius * 1.6 * Math.cos(angle) ]
    end
  end
end
