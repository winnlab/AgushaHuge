express = require 'express'

Age = require './admin/age'
Article = require './admin/article'
ArticleType = require './admin/articleType'
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

Router.use '/faq/:id?', FAQ.rest

Router.use '/article/img', Article.restFile
Router.use '/article/:id?', Article.rest

#########################

exports.Router = Router
exports.layoutPage = Main.layout