mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

getConsultationType = (type) ->
	switch type
		when 0
			return {
				id: 0
				name: 'К специалисту'
			}
		when 1
			return {
				id: 1
				name: 'К сообществу'
			}
		else
			throw new Error "Incorrect consultation type: #{type}"
			return {
				id: -1
				name: '//ошибка//'
			}


schema = new mongoose.Schema
	name:
		type: String
		required: true
	text:
		type: String
		required: true
	type: #0 - specialist, 1 - community
		type: Number
		require: true
		default: 0
		get: getConsultationType
	author:
		type: ObjectId
		ref: 'Client'
	created:
		type: Date
		default: moment
		requried: true
	active:
		type: Boolean
		default: true
	specialist:
		type: ObjectId
		ref: 'User'
	years:
		type: ObjectId
		ref: 'Years'
	theme:
		type: ObjectId
		ref: 'Theme'
	tag: [
		type: ObjectId
		name: 'Tag'
	]
	answers: [
		type: ObjectId
		ref: 'Answer'
	]
	closed:
		type: Boolean
		default: false
,
	collection: 'consultation'

module.exports = mongoose.model 'Consultation', schema
