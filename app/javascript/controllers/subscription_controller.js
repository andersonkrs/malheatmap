import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { url: String }

  connect () {
    if (this.urlValue) {
      window.Turbo.visit(this.urlValue, { action: 'replace' })
    }
  }
}
