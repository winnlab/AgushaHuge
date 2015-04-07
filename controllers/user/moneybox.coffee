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
				[
					'/img/user/moneybox/slunyavchik/slunyavchik_1.jpg'
				]
				[
					'/img/user/moneybox/slunyavchik/slunyavchik_2.jpg'
				]
				[
					'/img/user/moneybox/slunyavchik/slunyavchik_3.jpg'
				]
				[
					'/img/user/moneybox/slunyavchik/slunyavchik_4.jpg'
				]
				[
					'/img/user/moneybox/slunyavchik/slunyavchik_5.jpg'
				]
			]
			lvl.prizeName = 'Силиконовый слюнявчик'
			lvl.prizeQty = '5 наборов'
		if lvl.points is 400
			lvl.prizes = [
				[
					'/img/user/moneybox/polotenca/polotence_1.jpg'
				]
				[
					'/img/user/moneybox/polotenca/polotence_2.jpg'
				]
				[
					'/img/user/moneybox/polotenca/polotence_3.jpg'
				]
				[
					'/img/user/moneybox/polotenca/polotence_4.jpg'
				]
				[
					'/img/user/moneybox/polotenca/polotence_5.jpg'
				]
			]
			lvl.prizeName = 'Полотенце с капюшоном'
			lvl.prizeQty = '5 наборов'
		if lvl.points is 600
			lvl.prizes = [
				[
					'/img/user/moneybox/postel/postel_1.jpg'
				]
				[
					'/img/user/moneybox/postel/postel_2.jpg'
				]
				[
					'/img/user/moneybox/postel/postel_3.jpg'
				]
				[
					'/img/user/moneybox/postel/postel_4.jpg'
				]
			]
			lvl.prizeName = 'Детская постель'
			lvl.prizeQty = '4 комплекта'
		if lvl.points is 800
			lvl.prizes = [
				[
					'/img/user/moneybox/shapka_nabor/shapka1.jpg'
				]
				[
					'/img/user/moneybox/shapka_nabor/shapka2.jpg'
				]
			]
			lvl.prizeName = 'Милые шапочки'
			lvl.prizeQty = '5 штук'
		if lvl.points is 1000
			lvl.prizes = [
				[
					'/img/user/moneybox/chemodan/chemodan_1.jpg'
				]
				[
					'/img/user/moneybox/chemodan/chemodan_2.jpg'
				]
				[
					'/img/user/moneybox/chemodan/chemodan_3.jpg'
				]
			]
			lvl.prizeName = 'Детский чемодан Trunky'
			lvl.prizeQty = '3 штуки'
		return lvl
	cb null, prizes

winners_array = [
	date: '02.03.2015'
	data:
		novice: [
			'voynarovska1983@mail.ru'
			'ivanka.boyko.97@mail.ru'
			'dzyubak_88@mail.ru'
			'zaikina.in@ya.ru'
			'zhdanova_yulya92@mail.ru'
			'anna10081990@ukr.net'
			'bas1983@list.ru'
			'bymerz@mail.ru'
			'polishhuk1988@bk.ru'
			'marydavidchenko@gmail.com'
		]
		
		disciple: [
			'sekretar_vpu7@mail.ru'
			'barbashova23@mail.ru'
			'anastasiya_shtan@mail.ru'
			'12130406@list.ru'
			'trusko@mail.ru'
		]
		
		adept: [
			'diana190@ya.ru'
			'kika4ka.ru@mail.ru'
			'sweetlanna@ukr.net'
			'raselo4ek@rambler.ru'
		]
		
		expert: [
			'smuschfm@yahoo.com'
			'natusiamoja@gmail.com'
		]
		
		pro: [
			'vita-scorpi@yandex.ru'
		]
,
	date: '06.04.2015'
	data:
		novice: [
			'jarmoljuk-anastasija@rambler.ru'
			'iokharchenko@mail.ru'
			'svetulia78@ukr.net'
			'karatash.valentina@mail.ru'
			'litanatavita@mail.ru'
			'Beltan@meta.ua'
			'vitusja2007@ukr.net'
			'carenko_1982@mail.ru'
			'jacubishina.aleksandra@yandex.ru'
			'mir_oks@ukr.net'
		]
		
		disciple: [
			'tapoks84@gmail.com'
			'dowjenko.olga@yandex.ru'
			'valernat@gmail.com'
			'Lanina_nana@mail.ru'
			'natashenka1992@mail.ru'
		]
		
		adept: [
			'seleninnochka@rambler.ru'
			'mamby@yandex.ru'
			'yuliaqwas@mail.ru'
			'ludmila.kirneva@e-mail.ua'
		]
		
		expert: [
			'trusko@mail.ru'
		]
		
		pro: [
			'chuplakk@gmail.com'
		]
]

getWinners = (winners_item, callback) ->
	winners = winners_item.data
	
	fields = '_id profile.first_name profile.middle_name profile.last_name image.medium children.gender'
	
	sortOptions =
		lean: true
	
	async.parallel
		novice: (next2) ->
			options =
				$or: []
			
			lng = winners.novice.length
			while lng--
				winner = winners.novice[lng]
				options.$or.push
					email: winner
			
			Model 'Client', 'find', options, fields, sortOptions, next2
		disciple: (next2) ->
			options =
				$or: []
			
			lng = winners.disciple.length
			while lng--
				winner = winners.disciple[lng]
				options.$or.push
					email: winner
			
			Model 'Client', 'find', options, fields, sortOptions, next2
		adept: (next2) ->
			options =
				$or: []
			
			lng = winners.adept.length
			while lng--
				winner = winners.adept[lng]
				options.$or.push
					email: winner
			
			Model 'Client', 'find', options, fields, sortOptions, next2
		expert: (next2) ->
			options =
				$or: []
			
			lng = winners.expert.length
			while lng--
				winner = winners.expert[lng]
				options.$or.push
					email: winner
			
			Model 'Client', 'find', options, fields, sortOptions, next2
		pro: (next2) ->
			options =
				$or: []
			
			lng = winners.pro.length
			while lng--
				winner = winners.pro[lng]
				options.$or.push
					email: winner
			
			Model 'Client', 'find', options, fields, sortOptions, next2
	, callback

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'moneybox'
		lvls: exports.lvls
		user: req.user
	
	if req.params.test is 'test'
		data.test = true
	
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
			
			async.map winners_array, getWinners, next
		(results, next) ->
			data.winners = []
			
			resultsLength = results.length
			while resultsLength--
				result = results[resultsLength]
				data.winners[resultsLength] =
					date: winners_array[resultsLength].date
					data: results[resultsLength]
			
			View.render 'user/moneybox/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/moneybox/index: #{error}"
		return res.send error

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
