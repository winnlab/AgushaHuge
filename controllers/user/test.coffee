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

eachSeptemberAction = (doc, callback) ->
	console.log doc._id
	Moneybox.septemberAction doc._id, callback

exports.septemberAction = (req, res) ->
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