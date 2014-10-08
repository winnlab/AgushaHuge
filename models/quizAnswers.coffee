mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

Schema = new mongoose.Schema
	client:
		type: ObjectId
		ref: 'Client'
	date:
		type: Date
		default: moment
	article:
		type: ObjectId
		ref: 'Article'
	answer:
		type: ObjectId
		ref: 'Article.answer'
,
	collection: 'quizAnswer'

mongoose.model 'QuizAnswer', Schema