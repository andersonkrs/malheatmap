import { config, library, dom } from '@fortawesome/fontawesome-svg-core'
import {
  faTv,
  faBookReader,
  faSpinner,
  faCode,
  faClipboard,
  faFire
} from '@fortawesome/free-solid-svg-icons'
import Rails from '@rails/ujs'
import Turbolinks from 'turbolinks'

import 'channels'
import consumer from 'channels/consumer'

import '../../assets/stylesheets/application.scss'

require.context('../../assets/images', true)

config.mutateApproach = 'sync'

library.add(
  faTv,
  faBookReader,
  faSpinner,
  faCode,
  faClipboard,
  faFire
)

dom.watch()

Rails.start()
Turbolinks.start()

window.App = {}
App.consumer = consumer
