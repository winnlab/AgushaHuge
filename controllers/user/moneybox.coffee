_ = require 'lodash'
async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.lvls = [
	name: 'novice'
	label: 'Новичек'
	points: 200
,
	name: 'disciple'
	label: 'Ученик'
	points: 400
,
	name: 'adept'
	label: 'Знаток'
	points: 600
,
	name: 'expert'
	label: 'Эксперт'
	points: 800
,
	name: 'pro'
	label: 'Профи'
	points: 1000
,
	name: 'last'
	label: 'Профи'
	points: 1200
]

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'moneybox'
		lvls: exports.lvls

	async.waterfall [
		(next) ->
			Model 'Moneybox', 'aggregate', [
				$project:
					month:
						$month: '$time'
					year:
						$year: '$time'
					points: 1
					label: 1
					time: 1
			,
				$sort:
					year: 1
					time: -1
			,
				$group:
					_id:
						month: '$month'
						year: '$year'
					data:
						$push: '$$ROOT'
					allPoints:
						$sum: '$points'
			], next
		(docs, next) ->
			_.extend data, { actions: docs }
			next null
	], (err) ->
		if err
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/moneybox/index: #{error}"
			return res.send error
		View.render 'user/moneybox/index', res, data
