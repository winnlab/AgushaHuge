mongoose = require 'mongoose'

schema = new mongoose.Schema
	name:
		type: String
		required: true
	images:
		type: Array
,
	collection: 'gallery'

module.exports = mongoose.model 'Gallery', schema