mongoose = require 'mongoose'

schema = new mongoose.Schema
	name:
		type: String
		required: true
	counter:
		type: Number
		default: 0
,
	collection: 'quizAnswer'



module.exports = mongoose.model 'QuizAnswer', schema