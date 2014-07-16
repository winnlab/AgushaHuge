mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

setUpdateDate = () ->
	return moment()

schema = new mongoose.Schema
	date:
		type: Date
		required: false
		set: setUpdateDate
	desc_image: [
		type: String
		required: false
	]
	background: 
		type: String
		required: false
	title:
		type: String
		required: true
	desc_shorttext:
		type: String
		required: false
	desc_text:
		type: String
		required: false
	active:
		type: Boolean
		required: true
		default: false
	recommended:
		type: Boolean
		required: true
		default: false
	view_count:
		type: Number
		required: true
		default: 0
	like_count:
		type: Number
		required: true
		default: 0
	comment_count:
		type: Number
		required: true
		default: 0
	years:
		type: ObjectId
		ref: "Years"
	theme:
		type: ObjectId
		ref: "Theme"
	author:
		type: ObjectId
		ref: "Client"
,
	collection: 'contribution'

module.exports = mongoose.model 'Сontribution', schema
