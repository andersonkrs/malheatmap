import { config, library, dom } from '@fortawesome/fontawesome-svg-core'
import {
  faTv,
  faBookReader,
  faSpinner,
  faCode,
  faClipboard,
  faFire
} from '@fortawesome/free-solid-svg-icons'

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
