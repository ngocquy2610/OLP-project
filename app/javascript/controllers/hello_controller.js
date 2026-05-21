import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  connect() {
    if (this.hasTextValue) this.element.textContent = this.textValue
  }
}
