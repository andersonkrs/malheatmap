import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ "source" ]

  copy() {
    this.sourceTarget.focus()
    this.sourceTarget.select()
    navigator.clipboard.writeText(this.sourceTarget.value)
  }
}
