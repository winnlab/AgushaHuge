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
Watch = require './user/watch'
Rating = require './user/rating'
Test = require './user/test'
Contacts = require './user/contacts'
Download = require './user/download'

Middleware = require './helper/middleware'

Moneybox = require './user/moneybox'

User = require './user/user'


Theme = require '../lib/theme'
Feedback = require '../lib/feedback'

Router = express.Router()

#
#

Router.get '/', Main.index
Router.get '/registered', Main.registered
Router.get '/feed', Main.feed
Router.get '/articles', Main.articles

#

Router.use '/registration', Registration

Router.use '/login', Login

Router.use '/profile', Profile.router

#

Router.get '/products', Products.index
Router.post '/products/findAll', Products.findAll

#

Router.get '/product/:alias', Product.index

#

Router.get '/help/:tab', Help.index

Router.post '/send_feedback', Feedback.send

#

Router.get '/contacts', Contacts.index

#

Router.get '/download', Download.index

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

Router.post '/question/sendAnswer', Question.sendAnswer
Router.get '/question/:id', Question.findOne

#

Router.get '/search/:phrase', Search.index

#

Router.use '/user', User

#

Router.get '/moneybox/:test?', Moneybox.index
Router.get '/moneybox-points', Moneybox.getBox
Router.get '/moneybox-points-only', Moneybox.getPoints

#

Router.get '/messages', Messages.index
Router.post '/conversations/markConversationAsRead', Messages.markConversationAsRead
Router.get '/conversations', Messages.getConversations

#

Router.post '/like/toggleLike', Like.toggleLike
Router.post '/like/socialLike', Like.socialLike

Router.post '/watch/toggleWatch', Watch.toggleWatch

Router.get '/subscriptions', Subscription.get
Router.post '/subscribe', Subscription.save
Router.delete '/subscribe', Subscription.remove

#

Router.post '/commentaries/addCommentary', Commentary.add
Router.post '/commentaries/ratings/toggleRating', Rating.toggleRating

#

Router.get '/email_test', Test.email
# Router.get '/client_findAll', Test.client_findAll
# Router.get '/septemberAction', Test.septemberAction
# Router.get '/remakeActive', Test.remakeActive
# Router.get '/findOldActivated', Test.findOldActivated
Router.get '/ranks_count', Test.ranks_count
Router.get '/rankToExcel/:rank?', Test.rankToExcel
# Router.get '/email_moneybox_1', Test.email_moneybox_1
# Router.get '/email_moneybox_2', Test.email_moneybox_2
# Router.get '/email_winner_polotence', Test.email_winner_polotence
# Router.get '/email_8_marta', Test.email_8_marta
# Router.get '/email_apologize', Test.email_apologize
Router.get '/get_novice_winners', Test.get_novice_winners

#

exports.Router = Router