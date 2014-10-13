async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'

exports.findThemes = findThemes = (age, callback) ->
	searchOptions =
		active: true
	
	sortOptions =
		lean: true
	
	async.waterfall [
		(next) ->
			Model 'Age', 'findOne', next, {value: age}, '_id', sortOptions
		(doc) ->
			searchOptions.age_id = doc._id
			
			sortOptions.sort =
				position: 1
			
			Model 'Theme', 'find', callback, searchOptions, 'name', sortOptions
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/theme/findThemes: #{error}"
		View.ajaxResponse res, err

exports.findAll = (req, res) ->
	data = {}
	
	async.waterfall [
		(next) ->
			findThemes req.body.age, next
		(docs, next) ->
			data.themes = docs
			
			View.ajaxResponse res, null, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/theme/findAll: #{error}"
		View.ajaxResponse res, err