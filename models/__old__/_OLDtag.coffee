mongoose = require 'mongoose'

schema = new mongoose.Schema
	name:
		type: String
		required: true
		unique: true
,
	collection: 'tag'

module.exports = mongoose.model 'Tag', schema