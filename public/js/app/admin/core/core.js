import 'adminlte'

import Router from 'router'
import config from 'rConfig'

import 'js/app/admin/core/viewHelpers'
import 'js/app/admin/components/notification/'

new Router(document.body, config.router);