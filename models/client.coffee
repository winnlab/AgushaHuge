mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId
Validate = require '../utils/validate'

schema = new mongoose.Schema
	email:
		type: String
		required: true
		trim: true
		unique: true
		validate: Validate.email
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
	pic:
		big:
			type: String
		medium:
			type: String
		small:
			type: String
	social:
		vk:
			id:
				type: String
				unique: true
				required: true
			access_token:
				type: String
			refresh_token:
				type: String
		fb:
			id:
				type: String
				unique: true
				required: true
			access_token:
				type: String
			refresh_token:
				type: String
		ok:
			id:
				type: String
				unique: true
				required: true
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