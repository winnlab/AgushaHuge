express = require 'express'

Ages = require './admin/ages'
Articles = require './admin/articles'
Category = require './admin/category'
Certificate = require './admin/certificate'
Contributions = require './admin/contributions'
Clients = require './admin/clients'
Main = require './admin/main'
News = require './admin/news'
Products = require './admin/products'
Themes = require './admin/themes'
Tours = require './admin/tours'
Tour_records = require './admin/tour_records'
Years = require './admin/years'
Wysi = require './helper/wysi'

Router = express.Router()

#########################
Router.get '/', Main.index
Router.get '/login', Main.login
Router.get '/logout', Main.logout
Router.get '/dashboard', Main.dashboard

Router.post '/login', Main.do_login
#----------------#
Router.get '/products', Products.index
Router.get '/product/create', Products.create
Router.get '/product/edit/:id', Products.get
Router.get '/product/delete/:id', Products.delete

Router.post '/product', Products.save
Router.post '/product/mainPage', Products.saveMainPage
#----------------#
Router.get '/ages', Ages.index
Router.get '/age/create', Ages.create
Router.get '/age/edit/:id', Ages.get
Router.get '/age/delete/:id', Ages.delete

Router.post '/age', Ages.save
#----------------#
Router.get '/category', Category.index
Router.get '/category/create', Category.create
Router.get '/category/edit/:id', Category.get
Router.get '/category/delete/:id', Category.delete
Router.get '/category/position/:id', Category.position

Router.post '/category', Category.save
Router.post '/category/position', Category.savePosition
#----------------#
Router.get '/news', News.index
Router.get '/news/create', News.create
Router.get '/news/edit/:id', News.get
Router.get '/news/delete/:id', News.delete
Router.get '/news/deleteimg/:id/:img', News.deleteImage

Router.post '/news', News.save
#----------------#
Router.get '/themes', Themes.index

Router.post '/themes', Themes.save
#----------------#
Router.get '/years', Years.index

Router.post '/years', Years.save
#----------------#
Router.get '/articles', Articles.index
Router.get '/articles/create', Articles.create
Router.get '/articles/edit/:id', Articles.get
Router.get '/articles/delete/:id', Articles.delete
Router.get '/articles/deleteimg/:id/:img', Articles.deleteImage

Router.post '/articles', Articles.save
#----------------#
Router.get '/contributions', Contributions.index
Router.get '/contributions/create', Contributions.create
Router.get '/contributions/edit/:id', Contributions.get
Router.get '/contributions/delete/:id', Contributions.delete
Router.get '/contributions/deleteimg/:id/:img', Contributions.deleteImage

Router.post '/contributions', Contributions.save
#----------------#
Router.get '/certificate', Certificate.index
Router.get '/certificate/create', Certificate.create
Router.get '/certificate/edit/:id', Certificate.get
Router.get '/certificate/delete/:id', Certificate.delete

Router.post '/certificate', Certificate.save
#----------------#
Router.get '/clients', Clients.index
#----------------#
Router.get '/tours', Tours.index
Router.get '/tour/create', Tours.create
Router.get '/tour/edit/:id', Tours.get
Router.get '/tour/delete/:id', Tours.delete

Router.post '/tour', Tours.save
#----------------#
Router.get '/tour_records', Tour_records.index
Router.get '/tour_record/:id', Tour_records.item
#- upload helper for wysihtml5 -#
Router.get '/getAttached', Wysi.get
Router.post '/uploadWysi', Wysi.upload
########################

exports.Router = Router