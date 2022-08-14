import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    console.log("connected", this.urlValue)
    if (this.urlValue) {
      window.Turbo.visit(this.urlValue)
    }
  }
}
