mongoose = require 'mongoose'
tree = require 'mongoose-tree'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	active:
		type: Boolean
		required: true
		default: false
,
	collection: 'theme'

schema.plugin tree

module.exports = mongoose.model 'Theme', schema