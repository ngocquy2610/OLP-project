import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "messages", "status", "submit"]
  static values = {
    endpoint: String,
    signedIn: Boolean
  }

  connect() {
    this.csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    this.translations = this.buildTranslations()
    this.renderEmptyStateIfNeeded()
    this.scrollToBottom()
  }

  buildTranslations() {
    const lang = (document.documentElement.lang || "en").toLowerCase()
    const vi = lang.startsWith("vi")

    if (vi) {
      return {
        signInFirst: "Vui long dang nhap de dung chatbot.",
        typeBeforeSend: "Hay nhap tin nhan truoc khi gui.",
        waiting: "Dang gui tin nhan va cho phan hoi...",
        noResponse: "Khong co phan hoi tra ve.",
        connected: "Da ket noi.",
        connectionProbe: "Tra loi CONNECTED neu Rails co the ket noi den Python.",
        labelAssistant: "Tro ly",
        labelYou: "Ban",
        sending: "Dang gui...",
        send: "Gui",
        emptySignedIn: "Gui tin nhan de kiem tra ket noi chatbot Rails-Python.",
        emptySignedOut: "Dang nhap de gui tin nhan den chatbot."
      }
    }

    return {
      signInFirst: "Sign in first to test the chatbot connection.",
      typeBeforeSend: "Type a message before sending.",
      waiting: "Sending message to Rails and waiting for Python...",
      noResponse: "No response returned.",
      connected: "Connected. Rails received the message and returned a chatbot response.",
      connectionProbe: "Reply with CONNECTED if Rails can reach Python.",
      labelAssistant: "Assistant",
      labelYou: "You",
      sending: "Sending...",
      send: "Send",
      emptySignedIn: "Send a message to test the Rails-to-Python chatbot connection.",
      emptySignedOut: "Sign in to send a test message to the chatbot."
    }
  }

  async send(event) {
    event.preventDefault()

    if (!this.signedInValue) {
      this.setStatus(this.translations.signInFirst, true)
      return
    }

    const message = this.inputTarget.value.trim()
    if (!message) {
      this.setStatus(this.translations.typeBeforeSend, true)
      return
    }

    this.removeEmptyState()
    this.appendMessage("user", message)
    this.inputTarget.value = ""
    this.setLoading(true)
    this.setStatus(this.translations.waiting, false)

    try {
      const response = await fetch(this.endpointValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({ message })
      })

      const payload = await response.json()

      if (!response.ok) {
        throw new Error(payload.error || `Request failed with status ${response.status}`)
      }

      this.appendMessage("assistant", payload.response || this.translations.noResponse)
      this.setStatus(this.translations.connected, false)
    } catch (error) {
      this.appendMessage("assistant", `Error: ${error.message}`, true)
      this.setStatus(error.message, true)
    } finally {
      this.setLoading(false)
      this.scrollToBottom()
      this.inputTarget.focus()
    }
  }

  fillConnectionProbe() {
    this.inputTarget.value = this.translations.connectionProbe
    this.inputTarget.focus()
  }

  appendMessage(role, text, isError = false) {
    const wrapper = document.createElement("div")
    const bubble = document.createElement("div")
    const label = role === "assistant" ? this.translations.labelAssistant : this.translations.labelYou
    const renderedText = role === "assistant" && !isError ? this.parseSimpleMarkdown(text) : this.escapeHtml(text)

    wrapper.className = role === "assistant" ? "flex justify-start" : "flex justify-end"
    bubble.className = this.bubbleClasses(role, isError)
    bubble.innerHTML = `
      <div class="mb-2 text-[11px] font-semibold uppercase tracking-[0.18em] ${role === "assistant" ? "text-cyan-300" : "text-slate-300"}">${label}</div>
      <div class="break-words text-sm leading-6 prose prose-invert prose-sm max-w-none">${renderedText}</div>
    `

    wrapper.appendChild(bubble)
    this.messagesTarget.appendChild(wrapper)
  }

  bubbleClasses(role, isError) {
    if (isError) {
      return "max-w-[85%] rounded-3xl rounded-bl-md border border-red-400/30 bg-red-500/10 px-4 py-3 text-red-100 shadow-[0_10px_35px_rgba(220,38,38,0.12)]"
    }

    if (role === "assistant") {
      return "max-w-[85%] rounded-3xl rounded-bl-md border border-cyan-400/20 bg-slate-950/80 px-4 py-3 text-slate-100 shadow-[0_10px_35px_rgba(0,229,255,0.08)]"
    }

    return "max-w-[85%] rounded-3xl rounded-br-md border border-cyan-300/20 bg-cyan-400/15 px-4 py-3 text-cyan-50 shadow-[0_10px_35px_rgba(34,211,238,0.08)]"
  }

  setLoading(isLoading) {
    this.submitTarget.disabled = isLoading
    this.inputTarget.disabled = isLoading
    this.submitTarget.textContent = isLoading ? this.translations.sending : this.translations.send
  }

  setStatus(message, isError) {
    this.statusTarget.textContent = message
    this.statusTarget.className = isError ? "rounded-2xl border border-red-400/30 bg-red-500/10 px-4 py-3 text-sm text-red-100" : "rounded-2xl border border-cyan-400/20 bg-cyan-500/10 px-4 py-3 text-sm text-cyan-100"
  }

  renderEmptyStateIfNeeded() {
    if (this.messagesTarget.children.length > 0) {
      return
    }

    const state = document.createElement("div")
    state.dataset.emptyState = "true"
    state.className = "rounded-3xl border border-dashed border-slate-700 bg-slate-950/40 px-5 py-8 text-center text-sm text-slate-400"
    state.textContent = this.signedInValue ? this.translations.emptySignedIn : this.translations.emptySignedOut
    this.messagesTarget.appendChild(state)
  }

  removeEmptyState() {
    const state = this.messagesTarget.querySelector("[data-empty-state='true']")
    if (state) {
      state.remove()
    }
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  parseSimpleMarkdown(text) {
    const lines = String(text).split(/\r?\n/)
    const htmlParts = []
    let inList = false

    const closeListIfNeeded = () => {
      if (inList) {
        htmlParts.push("</ul>")
        inList = false
      }
    }

    const inlineMarkdown = (input) => this.escapeHtml(input).replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")

    lines.forEach((line) => {
      const bullet = line.match(/^\s*\*\s+(.+)$/)

      if (bullet) {
        if (!inList) {
          htmlParts.push('<ul class="list-disc pl-6 space-y-1">')
          inList = true
        }

        htmlParts.push(`<li>${inlineMarkdown(bullet[1])}</li>`)
        return
      }

      closeListIfNeeded()

      if (!line.trim()) {
        htmlParts.push("<br>")
        return
      }

      htmlParts.push(`<p>${inlineMarkdown(line)}</p>`)
    })

    closeListIfNeeded()
    return htmlParts.join("")
  }

  escapeHtml(text) {
    return text
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}