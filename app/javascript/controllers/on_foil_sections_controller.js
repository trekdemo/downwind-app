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
    // highlightedValue id of the highlighted section, 0 for none (no section
    // starts at the epoch)
    highlighted: { type: Number, default: 0 },
  }

  // From a row (id param)
  enter({ params: { id } }) {
    this.highlightedValue = id
  }

  // From the map (id in the event detail)
  enterFromMap({ detail: { id } }) {
    this.highlightedValue = id
  }

  leave() {
    this.highlightedValue = 0
  }

  highlightedValueChanged(id) {
    this.rowTargets.forEach(row => row.toggleAttribute("data-highlighted", Number(row.dataset.onFoilSectionsIdParam) === id))
    if (this.hasMapOutlet) this.mapOutlet.highlightSection(id)
  }
}
