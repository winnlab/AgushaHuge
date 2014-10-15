moment = require 'moment'
mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId
Validate = require '../utils/validate'

schema = new mongoose.Schema
	email:
		type: String
		trim: true
		unique: true
		sparse: true
		validate: Validate.email
	created_at:
		type: Date
		default: moment
	activated_at:
		type: Date
	last_activity_at:
		type: Date
	active:
		type: Boolean
		default: false
	password:
		type: String
	profile:
		filling:
			type: Number
		first_name:
			type: String
			trim: true
		last_name:
			type: String
			trim: true
	image:
		type: String
	social:
		vk:
			id:
				type: String
				unique: true
				sparse: true
			access_token:
				type: String
			refresh_token:
				type: String
		fb:
			id:
				type: String
				unique: true
				sparse: true
			access_token:
				type: String
			refresh_token:
				type: String
		ok:
			id:
				type: String
				unique: true
				sparse: true
			access_token:
				type: String
			refresh_token:
				type: String
	children: [
		child_id:
			type: ObjectId
			ref: 'Children'
		photo:
			type: String
		name:
			type: String
		birth_date:
			type: Date
	]
,
	collection: 'client'

schema.methods.name = () ->
	"#{@first_name} #{@last_name}"

module.exports = mongoose.model 'Client', schema