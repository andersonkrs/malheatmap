import { Controller } from "stimulus"
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"

import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["notificationsContainer", "loaderContainer", "form", "subimitButton"]

  beforeSend () {
    this.clearNotifications()
  }

  onError (event) {
    const xhr = event.detail[2]
    this.showNotification(xhr.response)
  }

  onSuccess (event) {
    const xhr = event.detail[2]
    const processId = xhr.getResponseHeader("ProcessID")

    if (processId === null) {
      return
    }

    this.showLoader(xhr.response)
    this.waitForProcessing(processId)
  }

  onComplete () {
    this.formTarget.reset()
  }

  beforeCache () {
    Rails.enableElement(this.formTarget)
  }

  showNotification (content) {
    this.notificationsContainerTarget.innerHTML = content
  }

  clearNotifications () {
    this.notificationsContainerTarget.innerHTML = ""
  }

  showLoader (content) {
    this.formTarget.style.display = "none"
    this.loaderContainerTarget.innerHTML = content
  }

  hideLoader () {
    this.formTarget.style.display = ""
    this.loaderContainerTarget.innerHTML = ""
  }

  waitForProcessing (processId) {
    const controller = this

    consumer.subscriptions.create({ channel: "SubscriptionChannel", process_id: processId }, {
      received (data) {
        this.unsubscribe()

        if (data.status === "success") {
          Turbolinks.visit(data.user_url, { action: "advance" })
        } else {
          controller.hideLoader()
          controller.showNotification(data.template)
        }
      }
    })
  }
}
