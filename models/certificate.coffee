mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	name:
		type: String
		required: true
	image:
		type: String
,
	collection: 'certificate'

module.exports = mongoose.model 'Certificate', schema