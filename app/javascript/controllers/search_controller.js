import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      let pageField = this.element.querySelector('input[name="page"]')

      if (!pageField) {
        pageField = document.createElement("input")
        pageField.type = "hidden"
        pageField.name = "page"
        this.element.appendChild(pageField)
      }

      pageField.value = "1"
      this.element.requestSubmit()
    }, 300)
  }
}