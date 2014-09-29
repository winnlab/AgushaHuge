mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	years_id:
		type: ObjectId
		ref: "Years"
	parent_id:
		type: ObjectId
		ref: "Theme"
	active:
		type: Boolean
		required: true
		default: true
	position:
		type: Number
		default: 99
,
	collection: 'theme'

module.exports = mongoose.model 'Theme', schema