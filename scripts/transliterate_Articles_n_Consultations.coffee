require '../init/database'

async = require 'async'
mongoose = require 'mongoose'
translit = require 'transliteration.cyr'

Article = require '../models/article'
Consultation = require '../models/consultation'

async.parallel
	article: (cb) ->
		Article.find {}, (err, docs) ->
			if err
				return cb err

			if docs.length
				iterate = (item, cb2) ->
					item.transliterated = translit.transliterate item.title
					item.save cb2
				async.each docs, iterate, (err) ->
					console.log "Processed #{docs.length} articles..."
					cb err
	consultation: (cb) ->
		Consultation.find {}, (err, docs) ->
			if err
				return cb err

			if docs.length
				iterate = (item, cb2) ->
					item.transliterated = translit.transliterate item.name
					item.save cb2
				async.each docs, iterate, (err) ->
					console.log "Processed #{docs.length} consultations..."
					cb err
, (err, results) ->
	if err
		return console.error err

	console.log 'Processing completed without errors! Exiting...'
	process.exit()