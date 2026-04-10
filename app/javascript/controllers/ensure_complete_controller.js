import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String }

  connect() {
    this.submitBound = this.submitHandler.bind(this)
    this.element.addEventListener('submit', this.submitBound)
  }

  disconnect() {
    this.element.removeEventListener('submit', this.submitBound)
  }

  submitHandler(e) {
    const form = this.element
    const radios = Array.from(form.querySelectorAll('input[type="radio"][name^="answers"]'))
    const names = Array.from(new Set(radios.map(r => r.name)))

    for (const name of names) {
      if (!form.querySelector(`input[name="${name}"]:checked`)) {
        e.preventDefault()
        const msg = this.messageValue || 'Hãy hoàn thành toàn bộ bài kiểm tra trước khi nộp bài.'
        alert(msg)
        return
      }
    }
  }
}
