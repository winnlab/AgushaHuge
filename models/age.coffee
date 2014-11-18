mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	title:
		type: String
		required: true
	icon:
		normal:
			type: String
		hover:
			type: String
		fixture:
			type: String
	value:
		type: Number
	active:
		type: Boolean
		default: true
	position:
		type: Number
		default: 99
	desc:
		title:
			type: String
		subtitle:
			type: String
		text:
			type: String
		tagline:
			type: String
		image:
			normal:
				type: String
			expanded:
				type: String
,
	collection: 'age'

module.exports = mongoose.model 'Age', schema