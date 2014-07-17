mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	pid:
		type: ObjectId
		ref: "Theme"
	active:
		type: Boolean
		required: true
		default: true
,
	collection: 'theme'

module.exports = mongoose.model 'Theme', schema