mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	pid:
		type: ObjectId
		ref: "Years"
	active:
		type: Boolean
		required: true
		default: true
,
	collection: 'years'

module.exports = mongoose.model 'Years', schema