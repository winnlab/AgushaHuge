mongoose = require 'mongoose'

schema = new mongoose.Schema
	title:
		type: String
		required: true
	icon:
		type: String
		required: false
	hoverImage:
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
	desc_subsubtitle:
		type: String
		required: false
,
	collection: 'productAge'

module.exports = mongoose.model 'ProductAge', schema