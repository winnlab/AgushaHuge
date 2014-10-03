mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

getArticleType = (type) ->
	switch type
		when 0 then msg = "Новости"
		when 1 then msg = "Акции"
		when 2 then msg = "Кормление"
		when 3 then msg = "От специалиста"
		else throw new Error "Incorrect type index in Article model: #{type}"

	return {
		id: type
		msg: msg
	}

setUpdateDate = () ->
	return moment()

schema = new mongoose.Schema
	type: # 0 - news, 1 - sales, 2 - feeding, 3 -from spec
		type: Number
		required: true
		get: getArticleType
	date:
		type: Date
		required: false
		set: setUpdateDate
	desc_image: [
		type: String
		required: false
	]
	desc_title:
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
,
	collection: 'article'

schema.static 'findArticles', (cb) ->
	where = 
		"$or": [
			{type: 2}
			{type: 3}
		]
	@find where, cb

schema.static 'findNews', (cb) ->
	where = 
		"$or": [
			{type: 0}
			{type: 1}
		]
	@find where, cb

module.exports = mongoose.model 'oldArticle', schema
