import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    courseId: Number,
    addedMessage: String,
    failedMessage: String,
    errorMessage: String
  }

  add(event) {
    event.preventDefault()

    const courseId = this.courseIdValue
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    fetch('/cart_items', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ course_id: courseId })
    })
      .then(response => response.json())
      .then(data => {
        if (data && data.success) {
          const successMessage = data.message || this.addedMessageValue
          if (successMessage) this.showToast(successMessage)
          this.updateCartCount(data.count)
        } else {
          const failedMessage = data?.error || this.failedMessageValue || this.errorMessageValue
          if (failedMessage) this.showToast(failedMessage, true)
        }
      })
      .catch(err => {
        console.error(err)
        if (this.errorMessageValue) this.showToast(this.errorMessageValue, true)
      })
  }

  updateCartCount(count) {
    const nextCount = String(count)
    const desktopBadge = document.getElementById('cart-count')
    const mobileBadge = document.getElementById('cart-count-mobile')

    if (desktopBadge) desktopBadge.textContent = nextCount
    if (mobileBadge) mobileBadge.textContent = nextCount
  }

  showToast(message, isError = false) {
    const toast = document.createElement('div')
    toast.textContent = message
    toast.className = `fixed right-6 top-6 z-50 px-4 py-2 rounded shadow-lg text-white ${isError ? 'bg-red-600' : 'bg-green-600'}`
    document.body.appendChild(toast)
    setTimeout(() => { toast.style.opacity = '0'; toast.style.transition = 'opacity 400ms' }, 1800)
    setTimeout(() => { toast.remove() }, 2400)
  }
}
