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
	author:
		type: ObjectId
		ref: 'Client'
	specialist:
		type: ObjectId
		ref: 'User'
	active:
		type: Boolean
		required: true
		default: true
	closed:
		type: Boolean
		default: false
	type:
		name: 
			type: String
	age:
		value:
			type: String
		age_id:
			type: ObjectId
			ref: "Age"
	theme:
		name:
			type: String
		theme_id:
			type: ObjectId
			ref: "theme"
	answer: [
		_id:
			type: ObjectId
			unique: true
		author:
			type: ObjectId
			ref: 'Client'
		specialist:
			type: ObjectId
			ref: 'User'
		date:
			type: Date
			default: moment
		text:
			type: String
			required: true
		parent:
			type: ObjectId
			ref: 'Name'
	]
,
	collection: 'consultation'

module.exports = mongoose.model 'Consultation', schema
