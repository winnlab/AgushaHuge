mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

module.exports = (Name) ->
	unless Name
		return throw new Error 'No name provided for `message` fixture (models/helpers/message.coffee)'

	Schema = new mongoose.Schema
		author:
			type: ObjectId
			ref: 'Client'
		specialist:
			type: ObjectId
			ref: 'User'
		date:
			type: Date
			default: moment
		text:
			type: String
			required: true
		parent:
			type: ObjectId
			ref: Name
	,
		collection: Name.toLowerCase()

	mongoose.model Name, Schema