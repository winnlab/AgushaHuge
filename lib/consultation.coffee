async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'

exports.search = (regexp, callback) ->
	searchOptions =
		'$or': [
			'name': regexp
		,
			'text': regexp
		]
	
	Model 'Consultation', 'find', callback, searchOptions, null