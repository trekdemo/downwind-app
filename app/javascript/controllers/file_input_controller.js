import { Controller } from "@hotwired/stimulus"

// Shows the chosen file's name next to a file input and highlights the
// dropzone label while a file is dragged over it.
export default class extends Controller {
  static targets = ["input", "filename", "dropzone"]
  static classes = ["dragover"]

  change() {
    const file = this.inputTarget.files[0]

    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = file ? file.name : ""
    }
  }

  dragover(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.add(...this.dragoverClasses)
  }

  dragleave() {
    this.dropzoneTarget.classList.remove(...this.dragoverClasses)
  }

  drop(event) {
    this.dropzoneTarget.classList.remove(...this.dragoverClasses)

    const file = event.dataTransfer.files[0]
    if (!file) return

    event.preventDefault()
    this.inputTarget.files = event.dataTransfer.files
    this.change()
  }
}
