mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	client:
		type: ObjectId
		ref: "Client"
		required: true
	contribution:
		type: ObjectId
		ref: "Contribution"
		required: true
	answer:
		type: ObjectId
		required: true
	date:
		type: Date
		required: true
		default: moment
,
	collection: 'likes'

module.exports = mongoose.model 'Likes', schema