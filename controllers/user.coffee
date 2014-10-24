express = require 'express'

Main = require './user/main'
Registration = require './user/registration'
Login = require './user/login'
Products = require './user/products'
Product = require './user/product'
Help = require './user/help'
Encyclopedia = require './user/encyclopedia'
Article = require './user/article'
Poll = require './user/poll'
Production = require './user/production'

Theme = require '../lib/theme'

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

Router.get '/encyclopedia/:age?/:theme?', Encyclopedia.index

Router.get '/article/:alias?', Article.index
Router.get '/poll/:alias?', Poll.index

Router.post '/themes/findAll', Theme.findAll
Router.post '/articles/findAll', Article.findAll

#

Router.get '/production', Production.index

#

exports.Router = Router