import { Controller } from '@hotwired/stimulus'

// Helper for tracking events on elements
export default class extends Controller {
  static values = {
    eventName: { type: String, default: "Click" },
    eventSource: { type: String, default: "" }
  }

  connect() {
    if (this.eventSourceValue === "") {
      const metaTag = document.querySelector("meta[name='tracker-source']")

      if (metaTag && metaTag.content) {
        this.eventSourceValue = metaTag.content
      }
    }
  }

  sendEvent(event) {
    if (!window._paq) return

    let events = this.eventNameValue.split(";")
    if (events.length === 0) return

    if (this.eventSourceValue) {
      events = [this.eventSourceValue, ...events]
    }

    window._paq.push(['trackEvent', ...events, event.target.href])
  }
}
