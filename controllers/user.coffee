express = require 'express'

Main = require './user/main'
Registration = require './user/registration'
Login = require './user/login'
Products = require './user/products'
Product = require './user/product'
Help = require './user/help'

Router = express.Router()

#

Router.get '/', Main.index

#

Router.get '/registration', Registration.index

#

Router.get '/login', Login.index

#

Router.get '/products', Products.index
Router.post '/products/findAll', Products.findAll

#

Router.get '/product/:alias', Product.index

#

Router.get '/help', Help.index

#

exports.Router = Router