mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema 
	title:
		type: String
		required: true
	text:
		type: String
	image:
		type: String
	storage_life:
		type: Number
	storage_conditions:
		type: String
	composition:
		type: String
	volume:
		type: Number
	volumeType:
		type: Number
		required: true
		default: 0
	active:
		type: Boolean
		required: true
		default: false
	recommended:
		type: Boolean
	assorted:
		type: Boolean
		default: false
	recommendation:
		type: String
	age:
		type: ObjectId
		ref: "ProductAge"
		required: true
	certificate: [
		type: ObjectId
		ref: "Certificate"
	]
	category: [
		type: ObjectId
		ref: "ProductCategory"
	]
	age_level:
		type: Number
	alias:
		type: String
		unique: true
,
	collection: 'product'

schema.methods.getFormattedVolume = () ->
	volume = @volume
	
	switch @volumeType
		when 1
			postfix = 'г' 
			type = 'вес'
		else 
			postfix = 'л' 
			type = 'объем'
			
			if parseInt(volume) < 1000
				postfix = "м#{postfix}"
	
	newVolume = Math.round(volume / 100) / 10
	
	obj =
		volume: volume
		postfix: postfix
		type: type

module.exports = mongoose.model 'Product', schema