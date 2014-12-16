_ = require 'lodash'
async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.lvls = [
	name: 'novice'
	label: 'Новичок'
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

getMoneybox = (userId, cb) ->
	Model 'Moneybox', 'aggregate', [
		$match:
			client_id: userId
	,
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
	], cb

getPrizes = (cb) ->
	lvls = _.clone exports.lvls
	lvls.pop()
	prizes = _.map lvls, (lvl) ->
		if lvl.points is 200
			lvl.prizes = [
				'/img/user/moneybox/blue_slyunyavchyk.jpg'
				'/img/user/moneybox/green_slyunyavchyk.jpg'
			]
			lvl.prizeName = 'Силиконовый слюнявчик'
			lvl.prizeQty = '5 наборов'
		if lvl.points is 400
			lvl.prizes = [
				'/img/user/moneybox/red_towel.jpg'
				'/img/user/moneybox/yellow_towel.jpg'
			]
			lvl.prizeName = 'Полотенце с капюшоном'
			lvl.prizeQty = '5 наборов'
		if lvl.points is 600
			lvl.prizes = [
				'/img/user/moneybox/blue_bed.jpg'
				'/img/user/moneybox/colorful_bed.jpg'
			]
			lvl.prizeName = 'Детская постель'
			lvl.prizeQty = '4 комплекта'
		if lvl.points is 800
			lvl.prizes = [
				'/img/user/moneybox/red_hat.jpg'
				'/img/user/moneybox/green_legs.jpg'
			]
			lvl.prizeName = 'Милые шапочки'
			lvl.prizeQty = '5 штук'
		if lvl.points is 1000
			lvl.prizes = [
				'/img/user/moneybox/blue_trunky.jpg'
				'/img/user/moneybox/orange_trunky.jpg'
			]
			lvl.prizeName = 'Детский чемодан Trunky'
			lvl.prizeQty = '3 штуки'
		return lvl
	cb null, prizes

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'moneybox'
		lvls: exports.lvls
		user: req.user

	async.waterfall [
		(next) ->
			if req?.user?._id
				return getMoneybox req.user._id, next
			next null, null
		(docs, next) ->
			if data?
				_.extend data, { actions: docs }

			getPrizes next
		(docs, next) ->
			if docs?
				_.extend data, { prizes: docs }

			next null
	], (err) ->
		if err
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/moneybox/index: #{error}"
			return res.send error
		View.render 'user/moneybox/index', res, data

exports.getBox = (req, res) ->
	data =
		points: req?.user?.points
	async.waterfall [
		(next) ->
			getMoneybox req.user._id, next
		(docs, next) ->
			_.extend data, { actions: docs }
			next null
	], (err) ->
		View.ajaxResponse res, err, data

exports.getPoints = (req, res) ->
	data =
		points: req?.user?.points || 0

	View.ajaxResponse res, null, data
