mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	age_id: [
		type: ObjectId
		ref: "Age"
		sparse: true
	]
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
	image:
		type: String
,
	collection: 'theme'

schema.set('versionKey', false);

module.exports = mongoose.model 'Theme', schema