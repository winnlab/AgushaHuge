async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'

exports.search = (regexpWords, callback) ->
	searchOptions =
		'$and': []
		# '$text':
			# '$search': textString
	
	wordsLength = regexpWords.length
	while wordsLength--
		regexp = regexpWords[wordsLength]
		
		searchOptions['$and'].push
			'$or': [
				'title': regexp
			,
				'desc.text': regexp
			]
	
	Model 'Consultation', 'find', callback, searchOptions, null