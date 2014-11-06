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
QuizAnswer = require './user/quizAnswer'
Consultation = require './user/consultation'
Profile = require './user/profile'
Messages = require './user/messages'
Like = require './user/like'
Subscription = require './user/subscription'
Commentary = require './user/commentary'
Rating = require './user/rating'


Middleware = require './helper/middleware'

Moneybox = require './user/moneybox'

User = require './user/user'


Theme = require '../lib/theme'

Router = express.Router()

#

Router.get '/', Main.index
Router.get '/registered', Main.registered

#

# Router.get '/registration', Middleware.auth.isAuth()

Router.use '/registration', Registration

Router.use '/login', Login

Router.use '/profile', Profile.router

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

Router.get '/article/:id', Article.findOne
# Router.get '/article/:alias?', Article.index
Router.get '/poll/:alias?', Poll.index
Router.post '/pollVote', Article.saveAnswer

Router.post '/themes/findAll', Theme.findAll
Router.post '/articles/findAll', Article.findAll

#

Router.get '/production', Production.index

#

Router.get '/cards', Cards.index

#

Router.post '/consultation', Consultation.setConsultation

#

Router.get '/specialist', Specialist.index

#

Router.get '/question/:id', Question.findOne

#

Router.get '/search/:phrase', Search.index

#

Router.use '/user', User

#

Router.get '/moneybox', Moneybox.index

#

Router.get '/messages', Messages.index

#

Router.post '/like/toggleLike', Like.toggleLike

Router.get '/subscriptions', Subscription.get
Router.post '/subscribe', Subscription.save
Router.delete '/subscribe', Subscription.remove

#

Router.post '/commentaries/addCommentary', Commentary.add
Router.post '/commentaries/ratings/toggleRating', Rating.toggleRating

#

exports.Router = Router
