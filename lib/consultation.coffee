async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'

exports.search = (regexpWords, callback) ->
	sortOptions =
		lean: true
	
	searchOptions =
		'$or': []
	
	wordsLength = regexpWords.length
	while wordsLength--
		regexp = regexpWords[wordsLength]
		
		searchOptions['$or'].push
			'name': regexp
		
		searchOptions['$or'].push
			'text': regexp
	
	Model 'Consultation', 'find', callback, searchOptions, null, sortOptions