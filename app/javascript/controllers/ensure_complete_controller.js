import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String,
    timeLimit: Number,
    warning: { type: Number, default: 300 }
  }
  static targets = ["timerDisplay", "timerContainer"]

  connect() {
    this.submitBound = this.submitHandler.bind(this)
    this.element.addEventListener('submit', this.submitBound)

    this.timeRemaining = Number(this.timeLimitValue || 0)
    this.autoSubmitted = false

    if (this.hasTimerDisplayTarget && this.hasTimerContainerTarget) {
      this.updateTimerDisplay()
      if (this.timeRemaining > 0) {
        this.interval = setInterval(() => {
          this.timeRemaining -= 1
          this.updateTimerDisplay()

          if (this.timeRemaining <= 0) {
            this.stopTimer()
            this.submitOnTimeout()
          }
        }, 1000)
      }
    }
  }

  disconnect() {
    this.element.removeEventListener('submit', this.submitBound)
    this.stopTimer()
  }

  submitHandler(e) {
    const form = this.element

    if (form.querySelector('input[name="timeout_auto_submit"][value="1"]')) {
      return
    }

    const radios = Array.from(form.querySelectorAll('input[type="radio"][name^="answers"]'))
    const names = Array.from(new Set(radios.map(r => r.name)))

    for (const name of names) {
      if (!form.querySelector(`input[name="${name}"]:checked`)) {
        e.preventDefault()
        const msg = this.messageValue
        alert(msg)
        return
      }
    }
  }

  stopTimer() {
    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }
  }

  updateTimerDisplay() {
    const remaining = Math.max(this.timeRemaining, 0)
    const minutes = Math.floor(remaining / 60)
    const seconds = remaining % 60
    this.timerDisplayTarget.textContent = `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`

    this.timerContainerTarget.classList.remove("border-cyan-400/30", "bg-cyan-500/10", "border-orange-400/30", "bg-orange-500/10", "border-red-400/30", "bg-red-500/10")
    this.timerDisplayTarget.parentElement.classList.remove("text-cyan-100", "text-orange-100", "text-red-100")

    if (remaining <= 0) {
      this.timerContainerTarget.classList.add("border-red-400/30", "bg-red-500/10")
      this.timerDisplayTarget.parentElement.classList.add("text-red-100")
      return
    }

    if (remaining <= this.warningValue) {
      this.timerContainerTarget.classList.add("border-orange-400/30", "bg-orange-500/10")
      this.timerDisplayTarget.parentElement.classList.add("text-orange-100")
      return
    }

    this.timerContainerTarget.classList.add("border-cyan-400/30", "bg-cyan-500/10")
    this.timerDisplayTarget.parentElement.classList.add("text-cyan-100")
  }

  submitOnTimeout() {
    if (this.autoSubmitted || this.timeRemaining > 0) return
    this.autoSubmitted = true

    const timeoutFlag = document.createElement("input")
    timeoutFlag.type = "hidden"
    timeoutFlag.name = "timeout_auto_submit"
    timeoutFlag.value = "1"
    this.element.appendChild(timeoutFlag)

    this.element.requestSubmit()

    setTimeout(() => {
      Array.from(this.element.elements).forEach((el) => {
        if (el.name !== "timeout_auto_submit") el.disabled = true
      })
    }, 0)
  }
}
