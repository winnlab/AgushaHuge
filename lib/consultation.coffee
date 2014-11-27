async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'

exports.search = (textString, callback) ->
	searchOptions =
		'$text':
			'$search': textString
	
	Model 'Consultation', 'find', callback, searchOptions, null