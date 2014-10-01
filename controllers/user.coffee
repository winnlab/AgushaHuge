express = require 'express'

Main = require './user/main'
Registration = require './user/registration'
Login = require './user/login'

Router = express.Router()

#

Router.get '/', Main.index

#

Router.get '/registration', Registration.index

#

Router.get '/login', Login.index

#

exports.Router = Router