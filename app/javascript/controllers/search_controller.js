import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query"]
  static FOCUS_STATE_KEY = "courses-search-focus-state"

  connect() {
    this.restoreFocus()
    this.ensureFocus()
  }

  disconnect() {
    cancelAnimationFrame(this.submitFrame)
  }

  submit() {
    cancelAnimationFrame(this.submitFrame)

    this.submitFrame = requestAnimationFrame(() => {
      this.saveFocusState()

      let pageField = this.element.querySelector('input[name="page"]')

      if (!pageField) {
        pageField = document.createElement("input")
        pageField.type = "hidden"
        pageField.name = "page"
        this.element.appendChild(pageField)
      }

      pageField.value = "1"
      this.element.requestSubmit()
    })
  }

  saveFocusState() {
    if (!this.hasQueryTarget) return

    sessionStorage.setItem(
      this.constructor.FOCUS_STATE_KEY,
      JSON.stringify({
        path: window.location.pathname,
        start: this.queryTarget.selectionStart,
        end: this.queryTarget.selectionEnd
      })
    )
  }

  restoreFocus() {
    if (!this.hasQueryTarget) return

    const rawState = sessionStorage.getItem(this.constructor.FOCUS_STATE_KEY)
    if (!rawState) return

    let state

    try {
      state = JSON.parse(rawState)
    } catch {
      sessionStorage.removeItem(this.constructor.FOCUS_STATE_KEY)
      return
    }

    if (state.path !== window.location.pathname) {
      sessionStorage.removeItem(this.constructor.FOCUS_STATE_KEY)
      return
    }

    this.focusQueryWithRetry(() => {
      const max = this.queryTarget.value.length
      const start = Number.isInteger(state.start) ? Math.min(state.start, max) : max
      const end = Number.isInteger(state.end) ? Math.min(state.end, max) : max

      this.queryTarget.setSelectionRange(start, end)
      sessionStorage.removeItem(this.constructor.FOCUS_STATE_KEY)
    })
  }

  ensureFocus() {
    if (!this.hasQueryTarget) return

    const rawState = sessionStorage.getItem(this.constructor.FOCUS_STATE_KEY)
    if (rawState) return

    this.focusQueryWithRetry(() => {
      const position = this.queryTarget.value.length
      this.queryTarget.setSelectionRange(position, position)
    })
  }

  focusQueryWithRetry(afterFocus = () => {}) {
    if (!this.hasQueryTarget) return

    requestAnimationFrame(() => {
      this.queryTarget.focus({ preventScroll: true })
      afterFocus()

      // Turbo frame updates can still steal focus right after connect.
      setTimeout(() => {
        this.queryTarget.focus({ preventScroll: true })
        afterFocus()
      }, 20)

      setTimeout(() => {
        this.queryTarget.focus({ preventScroll: true })
        afterFocus()
      }, 80)
    })
  }
}