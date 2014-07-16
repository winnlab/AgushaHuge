mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

Time = require '../utils/time'

schema = new mongoose.Schema
	date:
		type: Date
		required: true
		get: Time.getDate
		set: Time.setDate
,
	collection: 'tour'

module.exports = mongoose.model 'Tour', schema