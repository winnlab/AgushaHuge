async = require 'async'

Logger = require './logger'
Model = require './model'

array = require '../utils/array'

distinctAndPopulate = (fieldname, modelname, callback) ->
	async.waterfall [
		(next) ->
			Model('Contribution', 'findArticles', null)
				.distinct fieldname, next
		(items, next) ->
			where = { $or: [] }
			for item in items
				where.$or.push _id: item

			Model modelname, 'find', callback, where, '-__v'
	], callback

exports.aggregateRelations = (docs, callback) ->
	async.parallel
		years: (next) ->
			distinctAndPopulate 'years', 'Years', next
		themes: (next) ->
			distinctAndPopulate 'theme', 'Theme', next
		authors: (next) ->
			distinctAndPopulate 'author', 'Client', next
		tags: (next) ->
			aggregation = [
				{ $unwind: '$tags'}
				{ $match: type: 0 }
				{
					$group: {
						_id: null
						ids: $push: '$tags'
						names: $push: '$title'
					}
				}
			]
			Model 'Contribution', 'aggregate', next, aggregation
	, (err, results) ->
		if err
			Logger.log 'info', "Error occured in contribution model / aggregateRelated:", err
		if results
			if docs
				for item in docs
					item.authorName = item.author?.name() or '{редакция}'

			tags = []
			for index in [0...results.tags[0].ids.length]
				tags.push {
					_id: results.tags[0].ids[index]
					name: results.tags[0].names[index]
				}

			return callback err, {
				contributions: docs
				years: results.years
				themes: results.themes
				authors: results.authors
				tags: tags
			}

exports.preloadData = (contribution, cb) ->
	if typeof contribution is 'function'
		cb = contribution
		contribution = {}

	async.parallel
		years: (next) ->
			Model 'Years', 'find', next, active: true, '-__v'
		theme: (next) ->
			async.waterfall [
				(next2) ->
					Model 'Theme', 'find', next2, active: true, '-__v'
				(docs) ->
					Model 'Theme', 'populate', next, docs, 'tags'
			], next
		client: (next) ->
			Model 'Client', 'find', next, active: true, '_id login status'
	, (err, results)->
		cb err if err

		results.contribution = contribution

		results.years = array.makeTreeForSelect results.years
		results.theme = array.makeTreeForSelect results.theme
		results.cTags = {}
		if contribution.tags
			for item in contribution.tags
				results.cTags[item] = true

		themeAdjusted = {}
		if results.theme
			for t in results.theme
				themeAdjusted[t._id] = t.tags

		results.themeAdjusted = JSON.stringify themeAdjusted
		results.themeAdjustedObject = themeAdjusted

		if results.contribution.author
			results.contribution.authorName = results.contribution.author.name()
		else
			results.contribution.authorName = '{редакция}'

		cb null, results