express = require 'express'

Age = require './admin/age'
Main = require './admin/main'
Theme = require './admin/themes'

Router = express.Router()

#########################

Router.get '/', Main.index
Router.get '/login', Main.login
Router.get '/logout', Main.logout

Router.post '/login', Main.doLogin
# --------------------- #

Router.use '/age/:id?', Age.rest
Router.use '/theme/:id?', Theme.rest

#########################

exports.Router = Router
exports.layoutPage = Main.layout