import { Controller } from "stimulus"

export default class extends Controller {
  onDismiss(event) {
    const notification = event.target.parentNode
    notification.parentNode.removeChild(notification)
  }
}
