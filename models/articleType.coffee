mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
		unique: true
,
	collection: 'articleType'

module.exports = mongoose.model 'ArticleType', schema