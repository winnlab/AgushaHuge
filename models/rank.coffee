mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema 
	name:
		type: String
		required: true
	points:
		type: Number
		required: true
	image:
		type: String
	active:
		type: Boolean
		default: true
	prize: [
		_id:
			type: ObjectId
			default: mongoose.Types.ObjectId
		name:
			type: String
		position:
			type: Number
			default: 99
		image: [
			type: String
		]
	]
,
	collection: 'rank'

module.exports = mongoose.model 'Rank', schema