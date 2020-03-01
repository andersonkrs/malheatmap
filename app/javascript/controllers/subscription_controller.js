import { Controller } from "stimulus"

import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["notificationsContainer", "loaderContainer", "form"]

  beforeSend() {
    this.clearNotifications()
  }

  onError(event) {
    const xhr = event.detail[2]
    this.showNotification(xhr.response)
  }

  onSuccess(event) {
    const xhr = event.detail[2]
    const processId = xhr.getResponseHeader("ProcessID")

    if (processId === null) {
      return
    }

    this.showLoader(xhr.response)
    this.waitForProcessUpdates(processId)
  }

  onComplete(_event) {
    this.formTarget.reset()
  }

  showNotification(content) {
    this.notificationsContainerTarget.innerHTML = content
  }

  clearNotifications() {
    this.notificationsContainerTarget.innerHTML = ""
  }

  showLoader(content) {
    this.formTarget.style.display = "none"
    this.loaderContainerTarget.innerHTML = content
  }

  hideLoader() {
    this.formTarget.style.display = ""
    this.loaderContainerTarget.innerHTML = ""
  }

  waitForProcessUpdates(processId) {
    let controller = this

    consumer.subscriptions.create({ channel: "SubscriptionChannel", process_id: processId }, {
      received(data) {
        this.unsubscribe()

        if (data.status == "success") {
          window.location.href = data.user_url
        } else {
          controller.hideLoader()
          controller.showNotification(data.template)
        }
      }
    })
  }
}
