async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Moneybox = require '../../lib/moneybox'

Client = require '../../lib/client'

stringUtil = require '../../utils/string'

exports.email = (req, res) ->
	email = 'hydra0@bigmir.net'
	email = 'hydraorc@gmail.com'
	# email = 'dkirpa@gmail.com'
	
	options =
		toName: 'Имя Фамилия'
		to: email
		subject: 'Агуша тест'
		friend:
			firstName: 'Имя'
	
	Client.sendMail 'spring_invite', options, (err, html) ->
		if err
			return res.send err
		
		res.send html

exports.client_findAll = (req, res) ->
	result = []
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, null, null, lean: true
		(docs, next) ->
			res.send docs
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/client_findAll: #{error}"
		res.send error

winners =
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

exports.remakeActive = (req, res) ->
	res.send 'Processing...'
	
	options =
		login:
			'$ne': null
		active: true
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id'
		(docs, next) ->
			console.log docs.length
			
			async.eachSeries docs, (doc, next2) ->
				doc.active = false
				
				doc.save next2
			, next
		() ->
			console.log 'remakeActive done'
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/remakeActive: #{error}"
		res.send error

eachSeptemberAction = (id, callback) ->
	console.log id
	Moneybox.septemberAction id, callback

exports.septemberActionOld = (req, res) ->
	res.send 'Processing...'
	
	options =
		login:
			'$ne': null
		active: true
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id'
		(docs, next) ->
			console.log docs.length
			
			async.eachSeries docs, eachSeptemberAction, next
		() ->
			console.log 'septemberAction done'
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/septemberAction: #{error}"
		res.send error

exports.septemberAction = (req, res) ->
	res.send 'Processing...'
	
	emails = [
		'dkirpa@gmail.com'
		'zmorbohdan@gmail.com'
	]
	
	async.eachSeries emails, (email, callback) ->
		console.log email
		
		async.waterfall [
			(next) ->
				theMail = new RegExp email, 'i'
				
				options =
					email:
						'$regex': theMail
				
				Model 'Client', 'findOne', next, options, '_id'
			(doc) ->
				if !doc
					return callback null
				
				Moneybox.septemberAction doc._id, callback
		], (err) ->
			if err
				error = err.message or err
				Logger.log 'info', "Error in controllers/user/test/septemberAction: #{error}"
				res.send error
	, (err) ->
		if err
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/test/septemberAction: #{error}"
			res.send error

exports.findOldActivated = (req, res) ->
	options =
		login: null
		points:
			$gt: 100
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '-_id email'
		(docs, next) ->
			console.log docs.length
			console.log docs
			
			res.send docs
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/septemberAction: #{error}"
		res.send error

exports.ranks_count = (req, res) ->
	async.waterfall [
		(next) ->
			async.parallel
				novice: (next2) ->
					options =
						points:
							$gt: -1
							$lt: 201
					
					Model 'Client', 'count', next2, options
				disciple: (next2) ->
					options =
						points:
							$gt: 200
							$lt: 401
					
					Model 'Client', 'count', next2, options
				adept: (next2) ->
					options =
						points:
							$gt: 400
							$lt: 601
					
					Model 'Client', 'count', next2, options
				expert: (next2) ->
					options =
						points:
							$gt: 600
							$lt: 801
					
					Model 'Client', 'count', next2, options
				pro: (next2) ->
					options =
						points:
							$gt: 800
							$lt: 1001
					
					Model 'Client', 'count', next2, options
			, next
		(results, next) ->
			data =
				novice:
					name: 'Новичок'
					count: results.novice
				
				disciple:
					name: 'Ученик'
					count: results.disciple
				
				adept:
					name: 'Знаток'
					count: results.adept
				
				expert:
					name: 'Эксперт'
					count: results.expert
				
				pro:
					name: 'Профи'
					count: results.pro
			
			res.send data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/ranks_count: #{error}"
		res.send error

exports.rankToExcel = (req, res) ->
	ranks =
		novice:
			$gt: -1
			$lt: 201
		
		disciple:
			$gt: 200
			$lt: 401
		
		adept:
			$gt: 400
			$lt: 601
		
		expert:
			$gt: 600
			$lt: 801
		
		pro:
			$gt: 600
			$lt: 1001
	
	rank = req.params.rank
	
	sortOptions =
		lean: true
		sort:
			'profile.first_name': 1
	
	options =
		email:
			'$ne': null
	
	filename = 'data.xlsx'
	
	if rank
		if ranks[rank]
			options.points = ranks[rank]
			filename = rank + '.xlsx'
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id email profile points children image', sortOptions
		(docs, next) ->
			docsLength = docs.length
			
			if docsLength
				while docsLength--
					client = docs[docsLength]
					client.first_name = stringUtil.title_case (if client.profile and client.profile.first_name then client.profile.first_name else '')
					client.last_name = stringUtil.title_case (if client.profile and client.profile.last_name then client.profile.last_name else '')
					client.middle_name = stringUtil.title_case (if client.profile and client.profile.middle_name then client.profile.middle_name else '')
					client.children = if client.children then client.children.length else ''
					client.image = if client.image and client.image.medium then true else ''
					if client.profile
						delete client.profile
				
				return res.xls filename, docs
			
			res.send 'Ничего не найдено'
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/rankToExcel: #{error}"

send_moneybox_1 = (res, doc, callback) ->
	name = doc.email
	
	if doc.profile
		if doc.profile.first_name
			name = doc.profile.first_name
	
		if doc.profile.last_name
			name += ' ' + doc.profile.last_name
	
	options =
		toName: stringUtil.title_case name
		to: doc.email
		subject: 'Копилка'
	
	console.log doc
	
	Client.sendMail 'moneybox_1', options, callback

exports.email_moneybox_1 = (req, res) ->
	sortOptions =
		lean: true
		skip: 0
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, null, '_id email profile', sortOptions
		(docs, next) ->
			console.log docs.length
			
			async.timesSeries docs.length, (n, next2) ->
				console.log n
				doc = docs[n]
				
				send_moneybox_1 res, doc, next2
			, next
		(results) ->
			console.log 'send_moneybox_1 done'
			res.send true
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/send_moneybox_1: #{error}"

send_moneybox_2 = (res, doc, callback) ->
	name = doc.email
	
	if doc.profile
		if doc.profile.first_name
			name = doc.profile.first_name
	
		if doc.profile.last_name
			name += ' ' + doc.profile.last_name
	
	options =
		toName: stringUtil.title_case name
		to: doc.email
		subject: 'Копилка'
	
	console.log doc
	
	Client.sendMail 'moneybox_2', options, callback

exports.email_moneybox_2 = (req, res) ->
	sortOptions =
		lean: true
		skip: 0
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, null, '_id email profile', sortOptions
		(docs, next) ->
			console.log docs.length
			
			async.timesSeries docs.length, (n, next2) ->
				console.log n
				doc = docs[n]
				
				send_moneybox_2 res, doc, next2
			, next
		(results) ->
			console.log 'send_moneybox_2 done'
			res.send true
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/send_moneybox_2: #{error}"

send_winner_polotence = (res, doc, callback) ->
	name = doc.email
	
	if doc.profile
		if doc.profile.first_name
			name = doc.profile.first_name
	
		if doc.profile.last_name
			name += ' ' + doc.profile.last_name
	
	options =
		toName: stringUtil.title_case name
		to: doc.email
		subject: 'Копилка'
		client:
			first_name: stringUtil.title_case doc.profile.first_name
	
	console.log doc
	
	Client.sendMail 'winner_polotence', options, callback

exports.email_winner_polotence = (req, res) ->
	sortOptions =
		lean: true
	
	options =
		$or: []
	
	lng = winners.disciple.length
	while lng--
		winner = winners.disciple[lng]
		options.$or.push
			email: winner
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id email profile.first_name profile.last_name', sortOptions
		(docs, next) ->
			console.log docs.length
			
			async.timesSeries docs.length, (n, next2) ->
				console.log n
				doc = docs[n]
				
				send_winner_polotence res, doc, next2
			, next
		(results) ->
			console.log 'email_winner_polotence done'
			res.send true
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/email_winner_polotence: #{error}"

send_winner_8_marta = (res, doc, callback) ->
	name = doc.email
	
	if doc.profile
		if doc.profile.first_name
			name = doc.profile.first_name
	
		if doc.profile.last_name
			name += ' ' + doc.profile.last_name
	
	options =
		toName: stringUtil.title_case name
		to: doc.email
		subject: 'Поздравление с 8 марта'
	
	console.log doc
	
	Client.sendMail '8_marta', options, callback

exports.email_8_marta = (req, res) ->
	sortOptions =
		lean: true
	
	options =
		email:
			'$ne': null
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id email profile.first_name profile.last_name', sortOptions
		(docs, next) ->
			console.log docs.length
			
			async.timesSeries docs.length, (n, next2) ->
				console.log n
				doc = docs[n]
				
				send_winner_8_marta res, doc, next2
			, next
		(results) ->
			console.log 'email_8_marta done'
			res.send true
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/email_8_marta: #{error}"

send_apologize = (res, doc, callback) ->
	name = doc.email
	
	if doc.profile
		if doc.profile.first_name
			name = doc.profile.first_name
	
		if doc.profile.last_name
			name += ' ' + doc.profile.last_name
	
	options =
		toName: stringUtil.title_case name
		to: doc.email
		subject: 'Извинение от разработчика'
	
	console.log doc
	
	Client.sendMail 'apologize', options, callback

exports.email_apologize = (req, res) ->
	sortOptions =
		lean: true
		limit: 2186
	
	options =
		email:
			'$ne': null
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id email profile.first_name profile.last_name', sortOptions
		(docs, next) ->
			console.log docs.length
			
			async.timesSeries docs.length, (n, next2) ->
				console.log n
				doc = docs[n]
				
				send_apologize res, doc, next2
			, next
		(results) ->
			console.log 'email_apologize done'
			res.send true
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/email_apologize: #{error}"

exports.get_novice_winners = (req, res) ->
	sortOptions =
		lean: true
	
	options =
		$or: []
	
	lng = winners.novice.length
	while lng--
		winner = winners.novice[lng]
		options.$or.push
			email: winner
	
	new_docs = []
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, 'email social contacts.phone', sortOptions
		(docs, next) ->
			dLength = docs.length
			while dLength--
				doc = docs[dLength]
				
				new_doc =
					email: doc.email
					phone: if doc.contacts and doc.contacts.phone then doc.contacts.phone else ''
					vk: if doc.social and doc.social.vk then doc.social.vk.id else ''
					ok: if doc.social and doc.social.ok then doc.social.ok.id else ''
					fb: if doc.social and doc.social.fb then doc.social.fb.id else ''
				
				new_docs.push new_doc
			
			return res.xls 'novice_winners.xls', new_docs
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/get_novice_winners: #{error}"