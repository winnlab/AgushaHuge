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
	date:
		type: Date
		required: true
		default: moment
,
	collection: 'views'

module.exports = mongoose.model 'Views', schema