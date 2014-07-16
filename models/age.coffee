mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	title:
		type: String
		required: true
	icon:
		type: String
		required: false
	level:
		type: Number
		required: true
	active:
		type: Boolean
		required: true
		default: false
	desc_title:
		type: String
		required: false
	desc_text:
		type: String
		required: false
	desc_image:
		type: String
		required: false
	desc_subtitle:
		type: String
		required: false
,
	collection: 'age'



module.exports = mongoose.model 'Age', schema