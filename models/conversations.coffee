mongoose = require 'mongoose'
moment = require 'moment'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	interlocutors: [
		client_id:
			type: ObjectId
			ref: 'Client'
		read:
			type: Boolean
			default: false
	]
	messages: [
		_id:
			type: ObjectId
			default: mongoose.Types.ObjectId
		type:
			type: String
			default: 'default'
		author:
			type: ObjectId
			ref: 'Client'
		title:
			type: String
			default: ''
		content:
			type: String
			default: ''
		date:
			type: Date
			required: true
			default: moment
	]
	updated:
		type: Date
		required: true
		default: moment
,
	collection: 'messages'

module.exports = mongoose.model 'Message', schema
