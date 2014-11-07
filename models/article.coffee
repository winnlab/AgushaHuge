moment = require 'moment'
mongoose = require 'mongoose'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	type:
		name:
			type: String
			required: true
			index: true
	updated:
		type: Date
		required: true
		default: moment
	title:
		type: String
		required: true
	transliterated:
		type: String
		unique: true
	desc:
		shorttext:
			type: String
		text:
			type: String
		images: [
			type: String
		]
	image:
		background:
			type: String
		S:
			type: String
		L:
			type: String
		XL:
			type: String

	active:
		type: Boolean
		required: true
		default: true
	recommended:
		type: Boolean
		required: true
		default: false
	position:
		type: Number
		default: 0
	hasBigView:
		type: Boolean
		default: false
	age: [
		_id:
			type: ObjectId
			ref: "Age"
			set: mongoose.Types.ObjectId
			sparse: true
		title:
			type: String
		fixture:
			type: String
	]
	theme: [
		_id:
			type: ObjectId
			ref: "Theme"
			set: mongoose.Types.ObjectId
			sparse: true
		name:
			type: String
		position:
			type: Number
			default: 0
		hasBigView:
			type: Boolean
			default: false
	]
	likes: [
		client:
			type: ObjectId
			ref: 'Client'
	]
	commentaries: [
		client:
			client_id:
				type: ObjectId
				ref: 'Client'
			profile:
				type: Object
				default: {}
			image:
				type: String

		content:
			type: String
			default: ''
		date:
			type: Date
			required: true
			default: moment
		image:
			type: String
			default: ''
		rating: [
			client:
				type: ObjectId
				ref: 'Client'
			value:
				type: Number
		]
		scoreInc:
			type: Number
			default: 0
		scoreDec:
			type: Number
			default: 0
	]
	is_quiz:
		type: Boolean
		default: false
	answer: [
		_id:
			type: ObjectId
			default: mongoose.Types.ObjectId
		text:
			type: String
		position:
			type: Number
		score:
			type: Number
			default: 0
		clients: [
			client:
				type: ObjectId
				ref: 'Client'
		]
	]
	counter:
		like:
			type: Number
			default: 0
		comment:
			type: Number
			default: 0
		view:
			type: Number
			default: 0
,
	collection: 'article'

schema.methods.name = -> @title

schema.pre 'save', (next) ->
	this.updated = moment()
	this.transliterated = translit.transliterate this.title

	next()

module.exports = mongoose.model 'Article', schema