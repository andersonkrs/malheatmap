// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as ActionCable from '@rails/actioncable'
import { Turbo } from '@hotwired/turbo-rails'
import 'controllers'

const { StreamActions } = Turbo

ActionCable.logger.enabled = false

StreamActions.redirect = function() {
  const href = this.getAttribute("path")
  const turboAction = this.getAttribute("turbo-action") || 'advance'

  if (href) {
    Turbo.visit(href, { action: turboAction })
  } else {
    console.warn("Failed to process redirected stream, no path defined", this)
  }
}
