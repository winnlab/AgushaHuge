moment = require 'moment'
mongoose = require 'mongoose'
mongoosePages = require 'mongoose-pages'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

cropperPosition =
	x:
		type: Number
	y:
		type: Number
	width:
		type: Number
	height:
		type: Number

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
		B:
			type: String
		S:
			type: String
		L:
			type: String
		XL:
			type: String
		dataB: cropperPosition
		dataS: cropperPosition
		dataL: cropperPosition
		dataXL: cropperPosition
	active:
		type: Boolean
		required: true
		default: true
	recommended:
		type: Boolean
		required: true
		default: false
	hideOnMain:
		type: Boolean
		required: true
		default: false
	position:
		type: Number
		unique: true
		index: true
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
			sparse: true
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

mongoosePages.anchor schema

module.exports = mongoose.model 'Article', schema