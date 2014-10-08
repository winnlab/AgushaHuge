mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

Validate = require '../utils/validate'
Time = require '../utils/time'

schema = new mongoose.Schema
	date:
		type: Date
		default: Date.now
		get: Time.getDate
	firstname:
		type: Array
		required: true
	lastname:
		type: String
		required: true
	patronymic:
		type: String
	email:
		type: String
		validate: Validate.email
	phone:
		type: String
	city:
		type: ObjectId
		ref: 'City'
	children: [
		name: String
		gender: Boolean
		age: Number
		withParents: Boolean
	]
	active:
		type: Boolean
		default: false
	is_read:
		type: Boolean
		default: false
	tour:
		type: ObjectId
		ref: 'Tour'
,
	collection: 'tour_record'

module.exports = mongoose.model 'Tour_record', schema