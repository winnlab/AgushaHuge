mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema 
	title:
		type: String
		required: true
	text:
		type: String
		required: false
	image:
		type: String
		required: false
	storage_life:
		type: Number
		required: true
	composition:
		type: String
		required: false
	volume:
		type: Number
		required: false
	active:
		type: Boolean
		required: true
		default: false
	recommended:
		type: String
		required: false
	age:
		type: ObjectId
		ref: "Age"
		required: true
	certificate: [
		type: ObjectId
		ref: "Certificate"
		required: false
	]
	category: [
		type: ObjectId
		ref: "Category"
		required: false
	]
	age_level:
		type: Number
		required: false
	main_page:
		type: Number
		required: false
		default: 0
,
	collection: 'product'



module.exports = mongoose.model 'Product', schema
