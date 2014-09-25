express = require 'express'

Main = require './user/main'

Router = express.Router()

#

Router.get '/', Main.index

#

exports.Router = Router