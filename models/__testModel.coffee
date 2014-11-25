mongoose = require 'mongoose'

schema = new mongoose.Schema
	string:
		type: String
	number:
		type: Number
	date:
		type: Date
	bool:
		type: Boolean
,
	collection: 'test'

module.exports = mongoose.model 'Test', schema