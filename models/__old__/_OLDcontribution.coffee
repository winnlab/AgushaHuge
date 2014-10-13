_ = require 'underscore'
moment = require 'moment'
mongoose = require 'mongoose'

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
		unique: false
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

findByType = (type, where, what, cb) ->
	if typeof where is 'string'
		what = where
		where = {}

	if typeof what is 'function'
		cb = what
		what = null

	if typeof where is 'function'
		cb = where
		where = {}
		what = null

	where = _.extend type: type, where

	@find where, what, cb

schema.statics.findArticles = (where, what, cb) ->
	findByType.call @, 0, where, what, cb
	

schema.statics.findQuizes = (where, what, cb) ->
	findByType.call @, 1, where, what, cb

module.exports = mongoose.model 'Contribution', schema
