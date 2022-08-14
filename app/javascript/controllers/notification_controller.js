import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close(event) {
    const notification = event.target.parentNode
    notification.parentNode.removeChild(notification)
  }
}
