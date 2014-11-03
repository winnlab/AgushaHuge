mongoose = require 'mongoose'
moment = require 'moment'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	transliterated:
		type: String
	text:
		type: String
		required: true
	updated:
		type: Date
		required: true
		default: moment
	author:
		author_id:
			type: ObjectId
			ref: 'Client'
		name:
			type: String
	specialist:
		specialist_id:
			type: ObjectId
			ref: 'User'
		name:
			type: String
	active:
		type: Boolean
		required: true
		default: true
	closed:
		type: Boolean
		default: false
	recommended:
		type: Boolean
		default: false
	encyclopedia:
		type: Boolean
		default: false
	type:
		name: 
			type: String
	age:
		title:
			type: String
		age_id:
			type: ObjectId
			ref: "Age"
		fixture:
			type: String
	theme:
		name:
			type: String
		theme_id:
			type: ObjectId
			ref: "Theme"
	answer: [
		_id:
			type: ObjectId
			unique: true
			required: true
			default: mongoose.Types.ObjectId
		author:
			author_id:
				type: ObjectId
				ref: 'Client'
			name:
				type: String
		specialist:
			_id:
				type: ObjectId
				ref: 'User'
			name:
				type: String
		date:
			type: Date
			default: moment
		text:
			type: String
			required: true
		parent:
			type: ObjectId
		counter:
			type: Number
			default: 0
	]
,
	collection: 'consultation'

schema.pre 'save', (next) ->
	this.updated = moment()
	this.transliterated = translit this.title

	next()

module.exports = mongoose.model 'Consultation', schema