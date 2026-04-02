import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { courseId: Number }

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
          this.showToast('Đã thêm vào giỏ hàng')
          const badge = document.getElementById('cart-count')
          if (badge) badge.textContent = data.count
        } else {
          this.showToast(data.error || 'Không thể thêm vào giỏ hàng', true)
        }
      })
      .catch(err => {
        console.error(err)
        this.showToast('Lỗi khi thêm vào giỏ hàng', true)
      })
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
