mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

LibSchema = require '../lib/schema'

schema = new mongoose.Schema
	title:
		type: String
	'icon.normal':
		type: String
	'icon.hover':
		type: String
	icon:
		normal:
			type: String
		hover:
			type: String
	value:
		type: Number
		required: true
	active:
		type: Boolean
		default: true
	position:
		type: Number
		default: 99
	'desc.image.normal':
		type: String
	'desc.image.expanded':
		type: String
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