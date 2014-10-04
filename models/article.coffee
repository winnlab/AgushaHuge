moment = require 'moment'
mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	type:
		name:
			type: String
			required: true
	updated:
		type: Date
		required: true
		default: moment
	title:
		type: String
		required: true
	desc:
		shorttext:
			type: String
		text:
			type: String
		images: [
			type: String
		]
	image: 
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
	age:
		age_id:
			type: ObjectId
			ref: "Age"
		value:
			type: Number
			require: true
	theme:
		name:
			type: String
		theme_id:
			type: ObjectId
			ref: "Theme"
,
	collection: 'article'

schema.pre 'save', (next) ->
	this.updated = moment()
	next()

module.exports = mongoose.model 'Article', schema