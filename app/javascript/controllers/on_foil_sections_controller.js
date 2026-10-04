import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="on-foil-sections"
//
// Owns which section on foil is highlighted, and shows it both in the list
// and on the map. Hovering or focusing a row highlights its section, and so
// does hovering the section on the map (map:section-enter).
export default class extends Controller {
  static targets = [
    "row", // rowTargets:HTMLTableRowElement[] one per section, in order
  ]
  static outlets = ["map"]
  static values = {
    // highlightedValue index of the highlighted section, -1 for none like
    // HTMLSelectElement#selectedIndex
    highlighted: { type: Number, default: -1 },
  }

  // From a row (index param) or from the map (index in the event detail)
  enter({ params, detail }) {
    this.highlightedValue = params.index ?? detail.index
  }

  leave() {
    this.highlightedValue = -1
  }

  highlightedValueChanged(index) {
    this.rowTargets.forEach((row, i) => row.toggleAttribute("data-highlighted", i === index))
    if (this.hasMapOutlet) this.mapOutlet.highlightSection(index)
  }
}
