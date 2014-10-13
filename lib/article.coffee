async = require 'async'

View = require './view'
Model = require './model'
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
				return Model 'Age', 'findOne', next, {value: age}, '_id', sortOptions
			
			next null
		theme: (next) ->
			if theme
				return Model 'Theme', 'findOne', next, {_id: theme}, '_id', sortOptions
			
			next null
	, (err, results) ->
		if err
			return callback err
		
		if results.age
			searchOptions.age =
				age_id: results.age._id
		
		if results.theme
			searchOptions.theme =
				theme_id: results.theme._id
		
		callback null, searchOptions

exports.findAll = (age, theme, callback) ->
	sortOptions =
		lean: true
	
	async.waterfall [
		(next) ->
			makeSearchOptions age, theme, next
		(searchOptions) ->
			Model 'Article', 'find', callback, searchOptions, null, sortOptions
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/article/findAll: #{error}"
		View.ajaxResponse res, err