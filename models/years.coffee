mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	active:
		type: Boolean
		required: true
		default: true
	position:
		type: Number
		default: 99
,
	collection: 'years'

module.exports = mongoose.model 'Years', schema