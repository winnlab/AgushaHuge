express = require 'express'

Age = require './admin/age'
Article = require './admin/article'
News = require './admin/news'
ArticleType = require './admin/articleType'
Certificate = require './admin/certificate'
Client = require './admin/clients'
Consultation = require './admin/consultation'
Gallery = require './admin/gallery'
FAQ = require './admin/faq'
Main = require './admin/main'
Product = require './admin/product'
ProductAge = require './admin/productAge'
ProductCategory = require './admin/productCategory'
Rank = require './admin/rank'
Theme = require './admin/themes'
User = require './admin/user'
Stats = require './admin/stats'
Partner = require './admin/partner'

Router = express.Router()

#########################

Router.get '/', Main.index
Router.get '/login', Main.login
Router.get '/logout', Main.logout

Router.post '/login', Main.doLogin
# --------------------- #

Router.use '/age/img', Age.restFile
Router.use '/age/:id?', Age.rest

# Router.use '/theme/img', Theme.restFile
# Router.use '/theme/:id?', Theme.rest
Router.use '/theme', Theme

Router.use '/articleType/:id?', ArticleType.rest

Router.use '/article', Article
Router.use '/news', News

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

Router.use '/rank/img', Rank.restFile
Router.use '/rank/:id?', Rank.rest

Router.use '/certificate/img', Certificate.restFile
Router.use '/certificate/:id?', Certificate.rest

Router.use '/productCategory/:id?', ProductCategory.rest

Router.use '/partner/img', Partner.restFile
Router.use '/partner/:id?', Partner.rest

# Random data getter without REST wrapper
Router.get '/user', User.get

Router.get '/stats/children', Stats.childrenAges

# TEMPORARY BENEATH#
# Router.post '/tmpUserRemove', (req, res) ->
#   ClientModel = require '../models/client'
#   async = require 'async'
#   string = req.body.email
#   emails = string.split ' '
#   if emails
#     async.each emails, (item, cb) ->
#       ClientModel.remove {email: new RegExp(".*#{item}.*", 'gi')}, cb
#     , (err) ->
#       res.send unless err then true else err
#   else
#     res.send 'No emails string aquired'
#
# Router.delete '/tmpUserRemove', (req, res) ->
#   require('../models/client').remove {}, (err) ->
#     res.send unless err then true else err
# 
# TEMPORARY ABOVE#

#########################

exports.Router = Router
exports.layoutPage = Main.layout
