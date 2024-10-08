import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
import annotationPlugin from 'chartjs-plugin-annotation';

Chart.register(...registerables, annotationPlugin);

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
    const element = this.hasCanvasTarget ? this.canvasTarget : this.element

    this.chart = new Chart(element.getContext("2d"), {
      type: this.typeValue,
      data: this.chartData,
      options: this.chartOptions,
    })
  }

  disconnect() {
    this.chart.destroy()
    this.chart = undefined
  }

  get chartData() {
    if (!this.hasDataValue) {
      console.warn("[@stimulus-components/chartjs] You need to pass data as JSON to see the chart.")
    }

    return this.dataValue
  }

  get chartOptions() {
    return {
      ...this.defaultOptions,
      ...this.optionsValue,
    }
  }

  get defaultOptions() {
    return {}
  }
}
