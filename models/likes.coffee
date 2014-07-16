mongoose = require 'mongoose'
moment = require 'moment'

Model = require '../lib/model'

ObjectId = mongoose.Schema.Types.ObjectId

updateParent = (_id) ->
	Model('Contribution', 'update', null, _id: _id, '$inc': {'count': 1}).exec()

	return _id

schema = new mongoose.Schema
	client:
		type: ObjectId
		ref: "Client"
	contribution:
		type: ObjectId
		ref: "Contribution"
		set: updateParent
	date:
		type: Date
		required: true
		default: moment
,
	collection: 'likes'

module.exports = mongoose.model 'Likes', schema