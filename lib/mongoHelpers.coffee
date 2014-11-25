async = require 'async'
_ = require 'lodash'

Model = require '../lib/mongooseTransport'
###
	options (Array | Object) - Object of collection parameters or array of same objects
	options.model (String) - Model name where needed field is
	options.field (String) - Field name which max value needed
	options.findQuery (String) - (OPTIONAL) Parameters using which collection will be filtered

	{return} (Number) - Returns maximum of maximums of each options objects field.
###
exports.getMaxFieldValue = (options, callback) ->
	unless _.isArray options
		options = [options]

	iterator = (item, next) ->
		unless _.isString item.model 
			return next '`model` property of each options object should be valid String.'

		unless _.isString item.field
			return next "Object with model name #{item.model} has no valid `field` property."

		if item.findQuery and not _.isObject item.findQuery
			return next "Object with model name #{item.model} has `findQuery` property, but it isn't an Object."

		query = []
		if item.findQuery
			query.push
				$match: item.findQuery

		isNested = 0 < item.field.indexOf '.'

		if isNested
			split = item.field.split '.'
			query.push
				$unwind: '$' + split[0]

			if item.findQuery
				query.push
					$match: item.findQuery

			query.push
				$project:
					position: "$#{item.field}"

		query.push
			$group:
				_id: null
				maxPosition:
					$max: if isNested then '$position' else "$#{item.field}"

		query.push
			$project:
				_id: 0
				max: '$maxPosition'

		Model item.model, 'aggregate', query, next

	async.map options, iterator, (err, results) ->
		max = if _.isArray(results) and results.length then results.shift()?[0]?.max or 0 else 0

		_.each results, (obj) ->
			max = Math.max obj?[0]?.max or 0, max

		callback err, max