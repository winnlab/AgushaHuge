mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	text:
		type: String
		required: true
	type: #0 - specialist, 1 - community
		type: Number
		require: true
		default: 0
	author:
		type: ObjectId
		ref: 'Client'
	created:
		type: Date
		default: moment
		requried: true
	active:
		type: Boolean
		default: false
	specialist:
		type: ObjectId
		ref: 'User'
	years:
		type: ObjectId
		ref: 'Years'
	theme:
		type: ObjectId
		ref: 'Theme'
	tag: [
		type: ObjectId
		name: 'Tag'
	]
	answers: [
		type: ObjectId
		ref: 'Answer'
	]
	closed:
		type: Boolean
		default: false
,
	collection: 'consultation'

module.exports = mongoose.model 'Consultation', schema
