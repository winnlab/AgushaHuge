mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	active:
		type: Boolean
		default: true
	
	title:
		type: String
		required: true
	
	image:
		type: String
	
	url:
		type: String
,
	collection: 'partner'

module.exports = mongoose.model 'Partner', schema