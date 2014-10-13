express = require 'express'

Age = require './admin/age'
Article = require './admin/article'
ArticleType = require './admin/articleType'
Client = require './admin/clients'
Consultation = require './admin/consultation'
FAQ = require './admin/faq'
Main = require './admin/main'
Theme = require './admin/themes'

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

#########################

exports.Router = Router
exports.layoutPage = Main.layout