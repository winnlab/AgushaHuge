mongoose = require 'mongoose'

schema = new mongoose.Schema
	title:
		type: String
	text:
		type: String
	position:
		type: Number
		default: 99
	active:
		type: Boolean
		required: true
		default: true
,
	collection: 'faqs'

module.exports = mongoose.model 'FAQ', schema