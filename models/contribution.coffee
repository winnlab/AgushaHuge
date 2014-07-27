mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	type: # 0 - contribution, 1 - quiz
		type: Number
		required: true
	updated:
		type: Date
		required: true
	created:
		type: Date
		require: true
		default: moment
	desc_image: [
		type: String
		required: false
	]
	background: 
		type: String
		required: false
	title:
		type: String
		required: true
	desc_shorttext:
		type: String
		required: false
	desc_text:
		type: String
		required: false
	active:
		type: Boolean
		required: true
		default: true
	recommended:
		type: Boolean
		required: true
		default: false
	view_count:
		type: Number
		required: true
		default: 0
	like_count:
		type: Number
		required: true
		default: 0
	comment_count:
		type: Number
		required: true
		default: 0
	years:
		type: ObjectId
		ref: "Years"
	theme:
		type: ObjectId
		ref: "Theme"
	author:
		type: ObjectId
		ref: "Client"
	tags: [
		type: ObjectId
		ref: "Tag"
	]
	quiz: [
		type: ObjectId
		ref: 'QuizAnswer'
	]
,
	collection: 'contribution'

schema.static 'findArticles', (cb) ->
	where = type: 0

	@find where, cb

schema.static 'findQuizes', (cb) ->
	where = type: 1

	@find where, cb

module.exports = mongoose.model 'Contribution', schema
