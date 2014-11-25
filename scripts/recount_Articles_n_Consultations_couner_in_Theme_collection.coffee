require '../init/database'

async = require 'async'
mongoose = require 'mongoose'

Article = require '../models/article'
Consultation = require '../models/consultation'
Theme = require '../models/theme'

processTheme = (item, next1) ->
	async.parallel 
		article: (next2) ->
			Article.count 'theme._id': item._id, next2
		consultation: (next2) ->
			where =
				'theme._id': item._id
				encyclopedia: true

			Consultation.count where, next2
	, (err, results) ->
		if err
			return next1 err

		unless item.counter
			item.counter =
				article: 0

		item.counter.article = results.article + results.consultation
		item.save next1

async.waterfall [
	(next) ->
		Theme.update {}, {'counter.article' : 0}, {multi: true}, next
	(affected, results, next) ->
		Theme.find {}, next
	(docs, next) ->
		async.each docs, processTheme, next
], (err) ->
	if err
		console.error err
		process.exit()

	console.log 'Processing completed without errors! Exiting...'
	process.exit()