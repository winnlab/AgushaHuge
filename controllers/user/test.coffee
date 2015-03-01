async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Moneybox = require '../../lib/moneybox'

Client = require '../../lib/client'

stringUtil = require '../../utils/string'

exports.email = (req, res) ->
	email = 'hydra0@bigmir.net'
	email = 'hydraorc@gmail.com'
	
	options =
		toName: 'Имя Фамилия'
		to: email
		subject: 'Агуша тест'
	
	Client.sendMail 'moneybox_2', options, (err, html) ->
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
			'$ne': ''
			'$ne': 'undefined'
	
	filename = 'data.xlsx'
	
	if rank
		if ranks[rank]
			options.points = ranks[rank]
			filename = rank + '.xlsx'
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id email profile points', sortOptions
		(docs, next) ->
			docsLength = docs.length
			
			if docsLength
				while docsLength--
					client = docs[docsLength]
					client.first_name = stringUtil.title_case (if client.profile and client.profile.first_name then client.profile.first_name else '')
					client.last_name = stringUtil.title_case (if client.profile and client.profile.last_name then client.profile.last_name else '')
					client.middle_name = stringUtil.title_case (if client.profile and client.profile.middle_name then client.profile.middle_name else '')
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