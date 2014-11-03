require '../init/database'

mongoose = require 'mongoose'
translit = require 'transliteration.cyr'

Article = require '../models/article'
Consultation = require '../models/consultation'

Article.find {}, (err, docs) ->
	console.log docs.length
	if err
		return console.log 'Error in Article find: ', err

	if docs.length
		for article in docs
			article.transliterated = translit.transliterate article.title
			article.save()

Consultation.find {}, (err, docs) ->
	if err
		return console.log 'Error in Consultation find: ', err

	if docs.length
		for cons in docs
			cons.transliterated = translit.transliterate cons.name
			cons.save()