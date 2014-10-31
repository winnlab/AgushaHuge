express = require 'express'

Age = require './admin/age'
Article = require './admin/article'
ArticleType = require './admin/articleType'
Client = require './admin/clients'
Consultation = require './admin/consultation'
Gallery = require './admin/gallery'
FAQ = require './admin/faq'
Main = require './admin/main'
Product = require './admin/product'
ProductAge = require './admin/productAge'
Theme = require './admin/themes'
User = require './admin/user'

Router = express.Router()

#########################

Router.get '/', Main.index
Router.get '/login', Main.login
Router.get '/logout', Main.logout

Router.post '/login', Main.doLogin
# --------------------- #

Router.use '/age/img', Age.restFile
Router.use '/age/:id?', Age.rest

Router.use '/theme/img', Theme.restFile
Router.use '/theme/:id?', Theme.rest

Router.use '/articleType/:id?', ArticleType.rest

Router.use '/article/img', Article.restFile
Router.use '/article/:id?', Article.rest

Router.use '/faq/:id?', FAQ.rest

Router.use '/consultations/:id?', Consultation.rest

Router.use '/client/img', Client.restFile
Router.use '/client/:id?', Client.rest

Router.use '/gallery/img', Gallery.restFile
Router.use '/gallery/:id?', Gallery.rest

Router.use '/product/img', Product.restFile
Router.use '/product/:id?', Product.rest

Router.use '/productAge/img', ProductAge.restFile
Router.use '/productAge/:id?', ProductAge.rest

Router.get '/user', User.get

#########################

exports.Router = Router
exports.layoutPage = Main.layout