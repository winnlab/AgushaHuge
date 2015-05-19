_ = require 'lodash'
async = require 'async'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'

translit = require '../utils/translit'

exports.makeSearchOptions = makeSearchOptions = (age, theme, callback) ->
	searchOptions =
		active: true

	sortOptions =
		lean: true

	async.parallel
		age: (next) ->
			if age
				return Model 'Age', 'findOne', {value: age}, '_id', sortOptions, next

			next null
		theme: (next) ->
			if theme
				return Model 'Theme', 'findOne', {_id: theme}, '_id', sortOptions, next

			next null
	, (err, results) ->
		if err
			return callback err

		if results.age
			searchOptions['age._id'] = results.age._id

		if results.theme
			searchOptions['theme._id'] = results.theme._id

		callback null, searchOptions

exports.findAll = (age, theme, callback) ->
	articles = []

	sortOptions =
		'theme.position': -1
		lean: true

	async.waterfall [
		(next) ->
			makeSearchOptions age, theme, next
		(searchOptions, next) ->
			Model 'Article', 'find', searchOptions, {
				type: 1
				updated: 1
				title: 1
				transliterated: 1
				desc: 1
				image: 1
				recommended: 1
				hasBigView: 1
				age: 1
				likes: 1
				commentaries: 1
				is_quiz: 1
				answer: 1
				counter: 1
				theme: { $elemMatch: { _id: theme } }
			}, sortOptions, callback
		(docs, next) ->
			articles = docs
			searchOptions.encyclopedia = true
			Model 'Consultation', 'find', searchOptions, null, { lean: true }, next
		(docs, next) ->
			articles.concat docs
			callback articles
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/article/findAll: #{error}"
		View.ajaxResponse res, err

exports.search = (userId, textString, callback) ->
	searchOptions =
		'$text':
			'$search': textString

	Model 'Article', 'find', searchOptions, '_id', (err, data) ->
		return callback err if err
		return getArticlesData userId, { _id: $in: _.pluck data, '_id' }, callback

exports.getArticlesData = getArticlesData =  (userId, query, cb) ->
	query = Model 'Article', 'find', query or {}, '
		-desc.text -image.dataB -image.dataL -image.dataS -image.dataSOCIAL -image.dataXL
	', { lean: true }, null
	query.select {
		likes: { $elemMatch: 'client': userId }
		commentaries: { $elemMatch: 'client.client_id': userId },
		answer: { $elemMatch: 'clients.client': userId }
	}
	query.exec cb

exports.similarArticles = (userId, themes, ages, cb, articleId = null) ->
	query = {}
	query._id = $ne: articleId if articleId
	fields = '_id updated'
	options = { limit: 9, sort: 'updated', lean: true }

	async.parallel
		theme: (proceed) ->
			themeQuery = _.extend query, 'theme._id': $in: themes
			Model 'Article', 'find', themeQuery, fields, options, proceed
		age: (proceed) ->
			ageQuery = _.extend query, 'age._id': $in: ages
			Model 'Article', 'find', ageQuery, fields, options, proceed
	, (err, data) ->
		return cb err if err
		if data.theme.length >= 3
			return getArticlesData userId, { _id: $in: _.pluck data.theme, '_id' }, cb

		return getArticlesData userId, { _id: $in: _.pluck data.age, '_id' }, cb
