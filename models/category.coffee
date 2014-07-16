mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	name:
		type: String
		required: true
	active:
		type: Boolean
		required: true
		default: false
,
	collection: 'category'



module.exports = mongoose.model 'Category', schema