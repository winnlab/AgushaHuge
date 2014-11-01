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
Cards = require './user/cards'
Specialist = require './user/specialist'
Question = require './user/question'
Search = require './user/search'
Middleware = require './helper/middleware'

Theme = require '../lib/theme'

Router = express.Router()

#

Router.get '/', Main.index

#

Router.get '/registration', Middleware.auth.isAuth()

Router.use '/registration', Registration

#

# Router.get '/login', Middleware.auth.isAuth(), Login.index

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

Router.get '/cards', Cards.index

#

Router.get '/specialist', Specialist.index

#

Router.get '/question', Question.index

#

Router.get '/search/:phrase', Search.index

#

# Router.get '/login',

exports.Router = Router