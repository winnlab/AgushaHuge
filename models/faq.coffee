mongoose = require 'mongoose'

schema = new mongoose.Schema
	title:
		type: String
	text:
		type: String
,
	collection: 'faqs'

module.exports = mongoose.model 'FAQ', schema