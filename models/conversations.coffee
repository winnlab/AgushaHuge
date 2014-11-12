mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	interlocutors: [
		client:
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
		file:
			type: String
			default: ''
	]
	type:
		type: String
		default: 'default'
	updated:
		type: Date
		required: true
		default: moment
,
	collection: 'conversations'

module.exports = mongoose.model 'Conversation', schema
