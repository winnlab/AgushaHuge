mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema 
	title:
		name: String
		required: true
	points:
		type: Number
		required: true
	image:
		type: String
	prize: [
		title:
			name: String
			required: true
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