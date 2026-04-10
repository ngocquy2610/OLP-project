import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: Number }

  connect() {
    this.durationValue = this.durationValue || 4000
    // show only when there are messages
    if (!this.element.querySelector('[data-flash-message]')) return

    // ensure visible
    this.element.classList.remove('opacity-0', 'pointer-events-none')
    this.element.classList.add('opacity-100')

    this.timeout = setTimeout(() => this.hide(), this.durationValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  hide() {
    this.element.classList.add('transition', 'duration-300', 'opacity-0')
    this.element.classList.add('pointer-events-none')
    setTimeout(() => this.element.remove(), 300)
  }

  close(e) {
    e.preventDefault()
    this.hide()
  }
}
