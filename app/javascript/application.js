// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from '@hotwired/turbo-rails'
import '@rails/actioncable'
import "@rails/request.js"
import 'controllers'

const { StreamActions } = Turbo

StreamActions.redirect = function() {
  const href = this.getAttribute("path")
  const turboAction = this.getAttribute("turbo-action") || 'advance'

  if (href) {
    Turbo.visit(href, { action: turboAction })
  } else {
    console.warn("Failed to process redirected stream, no path defined", this)
  }
}
