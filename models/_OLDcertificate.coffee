mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

LibSchema = require '../lib/schema'

schema = new mongoose.Schema
	name:
		type: String
		required: true
	image:
		type: String
		required: true
,
	collection: 'certificate'

LibSchema.init schema, 'image'

module.exports = mongoose.model 'Certificate', schema