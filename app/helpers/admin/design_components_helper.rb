module Admin::DesignComponentsHelper
  # Every colour the UI uses, named by the role it plays. Tailwind colours
  # carry their palette token; colours hard-coded in Ruby or JS (charts, map)
  # carry the hex instead, as Tailwind never sees them.
  #
  # The role names are proposals for the semantic theme tokens.
  COLOR_ROLES = [
    {
      group: "Surfaces",
      colors: [
        { role: "surface-canvas", token: "slate-950", usage: "Page background, sticky header (/80), route preview backdrop (/60), focus-ring offset, text on primary button. Also the theme-color meta tag (#020617)." },
        { role: "surface-raised", token: "slate-900", usage: "Cards, inputs, inactive filter pills, table head (/50), upload dropzone (/50), map loading overlay (/40). Chart tooltip background (#0f172a)." },
        { role: "surface-sunken", token: "slate-800", usage: "Secondary button, ghost/radio hover, table row hover (/50), avatar, skeleton blocks, progress track, dropzone icon circle." }
      ]
    },
    {
      group: "Borders",
      colors: [
        { role: "border-card", token: "white", alpha: 5, usage: "Hairline ring around cards (ring-white/5)." },
        { role: "border-subtle", token: "slate-800", usage: "Header bottom border, card-header divider, table dividers, inactive filter pill ring. Chart grid and tooltip border (#1e293b)." },
        { role: "border-default", token: "slate-700", usage: "Input and radio rings, secondary button ring and hover background, dashed dropzone border, spinner track, badge-slate background (/40)." },
        { role: "border-strong", token: "slate-600", usage: "Map spinner track, badge-slate ring (/40)." }
      ]
    },
    {
      group: "Text",
      colors: [
        { role: "text-strong", token: "slate-50", usage: "Page titles (h1), stat values." },
        { role: "text-emphasis", token: "slate-100", usage: "Card and section headings, logo, secondary button text, hover text, primary table cell. Chart tooltip title (#f1f5f9)." },
        { role: "text-default", token: "slate-200", usage: "Body text (on <body>), table cells, dropzone prompt, empty-state heading." },
        { role: "text-secondary", token: "slate-300", usage: "Form labels, ghost button, badge-slate, radio option text, avatar initial. Chart tooltip body (#cbd5e1)." },
        { role: "text-muted", token: "slate-400", usage: "Stat/card/table-head labels, units, dates, helper text, inactive nav. Chart ticks and legend (#94a3b8)." },
        { role: "text-placeholder", token: "slate-500", usage: "Input placeholders." },
        { role: "text-faint", token: "slate-600", usage: "Empty-state illustration icon, route outline behind the map." },
        { role: "text-on-danger", token: "white", usage: "Danger button text." }
      ]
    },
    {
      group: "Accent (brand)",
      colors: [
        { role: "accent-text", token: "cyan-300", usage: "Active nav and filter pill, badge-cyan, selected radio, chosen file name, link hover." },
        { role: "accent", token: "cyan-400", usage: "Icons, links, focus rings, spinner head, title hover, dropzone hover border, route preview (/80). Progress chart line (#22d3ee)." },
        { role: "accent-solid", token: "cyan-500", usage: "Progress bar fill. Tinted backgrounds (/10, /5), rings (/30, /40), auth-page radial glow (/10). Foiling doughnut (#06b6d4)." }
      ]
    },
    {
      group: "Call to action",
      colors: [
        { role: "cta", token: "orange-500", usage: "Primary button background." },
        { role: "cta-hover", token: "orange-400", usage: "Primary button hover." }
      ]
    },
    {
      group: "Status",
      colors: [
        { role: "danger", token: "rose-600", usage: "Danger button background." },
        { role: "danger-hover", token: "rose-500", usage: "Danger button hover, alert and error tints (/10, /5) and rings (/30)." },
        { role: "danger-icon", token: "rose-400", usage: "Heart-rate card icon." },
        { role: "danger-text", token: "rose-300", usage: "Alert flash text, form error heading." },
        { role: "danger-text-soft", token: "rose-200", alpha: 90, usage: "Form error list items." },
        { role: "success", token: "emerald-500", usage: "Notice flash tint (/10) and ring (/30)." },
        { role: "success-icon", token: "emerald-400", usage: "Password-reset confirmation check." },
        { role: "success-text", token: "emerald-300", usage: "Notice flash text." },
        { role: "pending", token: "amber-500", usage: "badge-amber tint and ring (\"Analyzing…\")." },
        { role: "pending-text", token: "amber-300", usage: "badge-amber text." }
      ]
    },
    {
      group: "Activity kinds",
      colors: [
        { role: "kind-sup-dw", token: "cyan-500", usage: "badge-cyan: SUP downwind (text cyan-300)." },
        { role: "kind-sup-fwpu", token: "sky-500", usage: "badge-sky: SUP flatwater pump-up (text sky-300)." },
        { role: "kind-dockstart", token: "violet-500", usage: "badge-violet: Dockstart (text violet-300)." },
        { role: "kind-wingfoil", token: "teal-500", usage: "badge-teal: Wingfoil (text teal-300)." }
      ]
    },
    {
      group: "Data visualisation (hard-coded hex)",
      colors: [
        { role: "chart-series-secondary", hex: "#475569", usage: "Paddle-ups bars in the progress chart (ActivitiesController, = slate-600)." },
        { role: "chart-off-foil", hex: "#334155", usage: "Off-foil slice of the foiling doughnut (= slate-700)." },
        { role: "speed-slow", hex: "#1974D2", usage: "Map hotline and legend gradient start." },
        { role: "speed-medium", hex: "#FFFF00", usage: "Map hotline and legend gradient middle." },
        { role: "speed-fast", hex: "#FF0000", usage: "Map hotline at 75% only; missing from the legend gradient." },
        { role: "speed-max", hex: "#822EFF", usage: "Map hotline and legend gradient end." }
      ]
    }
  ].freeze

  # Background style for a colour swatch: the live theme variable for
  # Tailwind colours, so the swatch follows any theme change.
  #
  # @param color [Hash] an entry of COLOR_ROLES
  # @return [String] inline CSS
  def swatch_style(color)
    value = color[:hex] || "var(--color-#{color[:token]})"
    value = "color-mix(in oklab, #{value} #{color[:alpha]}%, transparent)" if color[:alpha]

    "background-color: #{value}"
  end

  # @param color [Hash] an entry of COLOR_ROLES
  # @return [String] e.g. "slate-950", "white/5" or "#1974D2"
  def swatch_label(color)
    return color[:hex] if color[:hex]

    [ color[:token], color[:alpha] ].compact.join("/")
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
          tag.h3(name, class: "text-sm font-semibold text-slate-100") +
            tag.code(source, class: "text-xs text-slate-500")
        end,
        tag.div(rendered, class: "rounded-lg bg-slate-950/60 p-4 ring-1 ring-inset ring-slate-800"),
        tag.details(class: "group text-xs") do
          tag.summary("HTML", class: "cursor-pointer text-slate-400 hover:text-slate-200") +
            tag.pre(tag.code(rendered.to_str.strip), class: "mt-2 max-h-64 overflow-auto rounded-lg bg-slate-950 p-3 text-slate-300 ring-1 ring-inset ring-slate-800")
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
