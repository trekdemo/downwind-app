import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
import annotationPlugin from 'chartjs-plugin-annotation';

Chart.register(...registerables, annotationPlugin);

// Night-ocean theme applied globally to every Chart.js instance.
const SLATE_400 = "#94a3b8"
const SLATE_800 = "#1e293b"
const RADIAL_TYPES = ["doughnut", "pie", "polarArea"]

Chart.defaults.color = SLATE_400
Chart.defaults.font.family = "Inter var, ui-sans-serif, system-ui, sans-serif"
Chart.defaults.borderColor = SLATE_800

// Deep-merges plain objects (arrays and other values are overwritten, not
// merged) so per-chart overrides (e.g. custom `scales`) still inherit the
// themed grid/tick colours nested under `defaultOptions`.
function deepMerge(target, source) {
  const output = { ...target }

  for (const key of Object.keys(source || {})) {
    const sourceValue = source[key]
    const targetValue = target ? target[key] : undefined

    if (isPlainObject(sourceValue) && isPlainObject(targetValue)) {
      output[key] = deepMerge(targetValue, sourceValue)
    } else {
      output[key] = sourceValue
    }
  }

  return output
}

function isPlainObject(value) {
  return typeof value === "object" && value !== null && !Array.isArray(value)
}

// Connects to data-controller="chart"
//
// Basic usage:
//   <canvas
//      data-controller="chart"
//      data-chart-data-value='{ "labels": ["January", "February", "March", "April", "May", "June", "July"], "datasets": [{ "label": "My First dataset", "backgroundColor": "transparent", "borderColor": "#3B82F6", "data": [37, 83, 78, 54, 12, 5, 99] }] }'
//      data-chart-options-value="<%= @chart_options.to_json %>"
//    ></canvas>
//
// More: https://www.stimulus-components.com/docs/stimulus-chartjs
// INFO: How to add shadow?
// https://codepen.io/kurkle/pen/zYYPagB#
export default class extends Controller {
  // canvasTarget: HTMLCanvasElement
  //
  // chart: Chart
  // typeValue: ChartType
  // optionsValue: ChartOptions
  // dataValue: ChartData
  //
  // hasDataValue: boolean
  // hasCanvasTarget: boolean

  static targets = ["canvas"]
  static values = {
    type: { type: String, default: "line" },
    data: Object,
    options: Object,
  }

  connect() {
    this.canvasElement = this.hasCanvasTarget ? this.canvasTarget : this.element
    this.buildChart()

    // Chart.js sets width/height/style directly on the canvas; a Turbo
    // morph refresh strips those (idiomorph doesn't know how to diff a
    // canvas bitmap), which blanks the chart. Rebuilding from scratch is
    // simpler and more robust than trying to restore the canvas in place.
    this.canvasElement.addEventListener("turbo:morph-element", this.redraw)
  }

  disconnect() {
    this.canvasElement.removeEventListener("turbo:morph-element", this.redraw)
    this.chart.destroy()
    this.chart = undefined
  }

  buildChart() {
    this.chart = new Chart(this.canvasElement.getContext("2d"), {
      type: this.typeValue,
      data: this.chartData,
      options: this.chartOptions,
    })
  }

  redraw = () => {
    this.chart.destroy()
    this.buildChart()

    // A morph can also change data-chart-*-value on the same tick, which
    // would otherwise trigger a redundant *ValueChanged update right after
    // this rebuild (which already reads the latest values).
    this.skipNextValueSync = true
    queueMicrotask(() => { this.skipNextValueSync = false })
  }

  // data-chart-data-value/-options-value can change without a DOM morph
  // (e.g. a Turbo Stream update rewriting the attribute in place), so keep
  // an already-connected chart in sync when that happens.
  dataValueChanged() {
    if (!this.chart || this.skipNextValueSync) return
    this.chart.data = this.chartData
    this.chart.update()
  }

  optionsValueChanged() {
    if (!this.chart || this.skipNextValueSync) return
    this.chart.options = this.chartOptions
    this.chart.update()
  }

  get chartData() {
    if (!this.hasDataValue) {
      console.warn("[@stimulus-components/chartjs] You need to pass data as JSON to see the chart.")
    }

    return this.dataValue
  }

  get chartOptions() {
    return deepMerge(this.defaultOptions, this.optionsValue)
  }

  get defaultOptions() {
    const options = {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        intersect: false,
        mode: "index",
      },
      plugins: {
        legend: {
          position: "bottom",
          labels: {
            usePointStyle: true,
            pointStyle: "circle",
            color: SLATE_400,
          },
        },
        tooltip: {
          backgroundColor: "#0f172a",
          titleColor: "#f1f5f9",
          bodyColor: "#cbd5e1",
          borderColor: SLATE_800,
          borderWidth: 1,
          padding: 10,
          usePointStyle: true,
        },
      },
      scales: {
        x: {
          grid: {
            display: false,
          },
          ticks: {
            color: SLATE_400,
          },
        },
        y: {
          grid: {
            color: SLATE_800,
          },
          ticks: {
            color: SLATE_400,
          },
        },
      },
    }

    // Radial charts (doughnut, pie, polarArea) have no cartesian axes.
    if (RADIAL_TYPES.includes(this.typeValue)) delete options.scales

    return options
  }
}
