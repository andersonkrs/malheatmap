import '@fortawesome/fontawesome-free/js/all'
import Rails from '@rails/ujs'
import Turbolinks from 'turbolinks'

import '../../assets/stylesheets/application.scss'
import 'channels'
import consumer from 'channels/consumer'

require.context('../../assets/images', true)

Rails.start()
Turbolinks.start()

window.App = {}
App.consumer = consumer
