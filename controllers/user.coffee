express = require 'express'

Main = require './user/main'
Registration = require './user/registration'
Login = require './user/login'
Products = require './user/products'

Router = express.Router()

#

Router.get '/', Main.index

#

Router.get '/registration', Registration.index

#

Router.get '/login', Login.index

#

Router.get '/products', Products.index

#

exports.Router = Router