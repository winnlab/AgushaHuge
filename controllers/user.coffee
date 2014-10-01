express = require 'express'

Main = require './user/main'
Registration = require './user/registration'

Router = express.Router()

#

Router.get '/', Main.index

#

Router.get '/registration', Registration.index

#

exports.Router = Router