async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Moneybox = require '../../lib/moneybox'

Client = require '../../lib/client'

exports.email = (req, res) ->
	# email = 'hydraorc@gmail.com'
	email = 'hydra0@bigmir.net'
	
	options =
		toName: 'Имя Фамилия'
		to: email
		subject: 'Агуша тест'
	
	Client.sendMail 'letter_regist_2', options, (err, html) ->
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

eachSeptemberAction = (id, callback) ->
	console.log id
	Moneybox.septemberAction id, callback

exports.septemberActionOld = (req, res) ->
	res.send 'Processing...'
	
	options =
		login:
			'$ne': null
	
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
		'deneshzka@mail.ru'
		'vip.chernichenko@mail.ru'
		'katarina-z@ukr.net'
		"davidenko_@i.ua"
		"len7206@yandex.ru"
		"aleksandra_govor@mail.ru"
		"xaecka90@mail.ru"
		"makarenko2504@rambler.ru"
		"valernat@gmail.com"
		"murinkav@mail.ru"
		"andrew.sygyda@gmail.com"
		"vanya.kostyuk.93@mail.ru"
		"kravchenkoanechka@yandex.ru"
		"dkirpa@gmail.com"
		"seninkasper@gmail.com"
		"pusyxa@i.ua"
		"tetyanka_ne@mail.ru"
		"nastja_sim88@mail.ru"
		"grebenschicova_dasha@ukr.net"
		"ylka-a_aleynik@mail.ru"
		"ligurina@ukr.net"
		"dimao2014@inbox.ru"
		"lesyaberd@mail.ru"
		"iracvik@rambler.ru"
		"frendnastya@mail.ru"
		"alesya8508@mail.ru"
		"demenko_lyudmila@mail.ru"
		"yan-bondarenk@yandex.ru"
		"raselo4ek@rambler.ru"
		"inna_cher@mail.ru"
		"max.shekera@gmail.com"
		"vitaliya7777@gmail.com"
		"Liliya-04.02@inbox.ru"
		"koskorotaev@gmail.com"
		"elena-borodach@mail.ru"
		"mariiiwka@mail.ru"
		"ruzhaya@meta.ua"
		"idea_90@mail.ru"
		"ezerskaya2015@yandex.ru"
		"v.nechayenko@peppermint.com.ua"
		"modnaya-kate@yandex.ru"
		"tatasja88@gmail.com"
		"imiti-2011@yandex.ua"
		"aqvador@list.ru"
		"croxmal@yandex.ru"
		"vita-scorpi@yandex.ru"
		"tatasja88@yandex.ru"
		"lybowv@mail.ru"
		"kisa191186@mail.ru"
		"masha.max@mail.ru"
	]
	
	async.eachSeries emails, (email, callback) ->
		console.log email
		
		async.waterfall [
			(next) ->
				theMail = new RegExp email, 'i'
				
				options =
					name:
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