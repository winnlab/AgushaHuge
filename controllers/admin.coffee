express = require 'express'

CategoryEncyclopedia = require './admin/categoryEncyclopedia'

Main = require './admin/main'

Router = express.Router()

#########################

Router.get '/', Main.index
Router.get '/login', Main.login
Router.get '/logout', Main.logout

Router.post '/login', Main.doLogin
# --------------------- #

Router.get '/years', CategoryEncyclopedia.years
Router.get '/themes', CategoryEncyclopedia.themes

#########################

exports.Router = Router
exports.layoutPage = Main.layout