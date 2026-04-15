import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    console.log("Submitting search form...")
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}