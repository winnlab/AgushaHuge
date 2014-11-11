async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'

exports.search = (words, callback) ->
	sortOptions =
		lean: true
	
	searchOptions =
		'$or': []
	
	wordsLength = words.length
	while wordsLength--
		word = words[wordsLength]
		regexp =  new RegExp '^' + word + '$', 'i'
		
		searchOptions['$or'].push
			'name': regexp
		
		searchOptions['$or'].push
			'text': regexp
	
	Model 'Consultation', 'find', callback, searchOptions, null, sortOptions