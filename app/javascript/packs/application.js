import Rails from '@rails/ujs'
import Turbolinks from 'turbolinks'

import 'channels'
import consumer from 'channels/consumer'

import '../../assets/stylesheets/application.scss'
import 'src/fontawesome.js'

require.context('../../assets/images', true)

Rails.start()
Turbolinks.start()

window.App = {}
App.consumer = consumer
