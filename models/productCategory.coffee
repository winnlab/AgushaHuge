mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	name:
		type: String
		required: true
	url_label:
		type: String
		required: true
		unique: true
	active:
		type: Boolean
		required: true
		default: true
,
	collection: 'productCategory'

module.exports = mongoose.model 'ProductCategory', schema