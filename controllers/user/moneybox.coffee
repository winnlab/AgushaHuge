async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'moneybox'
		lvls: [
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
	View.render 'user/moneybox/index', res, data
