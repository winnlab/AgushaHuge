async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Moneybox = require '../../lib/moneybox'

Client = require '../../lib/client'

exports.email = (req, res) ->
	# email = 'hydraorc@gmail.com'
	email = 'imhereintheshadows@gmail.com'
	
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
		login:
			'$ne': null
		points:
			$gt: 100
	
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next, options, '_id'
		(docs, next) ->
			console.log docs.length
			console.log docs
			
			async.eachSeries docs, eachSeptemberAction, next
		() ->
			console.log 'septemberAction done'
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/septemberAction: #{error}"
		res.send error