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
	
	async.waterfall [
		(next) ->
			ids = [
				'547cd1939bff864567b0ef73'
				'547ce793bf97cea768e0ff93'
				'547d746fbf97cea768e0ff94'
				'547d8a2ee75aa4e0779fb7e5'
				'547d962de75aa4e0779fb7ef'
				'54885b7e502ac2741cd01340'
				'54886c3e767dac151e00b297'
				'5488966044a4d9ab226c73d0'
				'5488c35bf071a851277b2b85'
				'54898d10fcb88e193982c3bb'
				'5489d344dd2bbfca3f4f1dae'
				'5489d8f4dd2bbfca3f4f1db6'
				'548a2128786376d04f19989f'
				'548b1b6edda26046034d2236'
				'548b3c8db2429b2306881d8c'
				'548b6d4e9248afe3089db1c6'
				'548c2ede370153a20e3b3fd7'
				'548d73cb19648bc63b212990'
				'548d8e7475173a833ca258df'
				'548e921668749dbd4012e93f'
				'548eb01ee1c0898d45ed9c47'
				'548f286498c377770b6f5efd'
				'548fdf15951817430f5e8a3e'
				'54900da0951817430f5e8afc'
				'54900e0a951817430f5e8b05'
				'549075e558b89f10183b212b'
				'549090a058b89f10183b2132'
				'5490a8a158b89f10183b217c'
				'54915d4c43b1ee581d991468'
				'54917db0b9efe4b12934b81b'
				'5491cc21296475be3b32fbef'
				'54920744296475be3b32fc23'
				'5492869b296475be3b32fc52'
				'54931235296475be3b32fcc1'
				'5493ecafdf2e83d54547e077'
				'5494412cdf2e83d54547e0e1'
				'54944d3edf2e83d54547e0e3'
				'54945f74c7d5f87c6555ff3e'
				'5494a2ccc7d5f87c6555ffa9'
				'5494abf4c7d5f87c6555fff3'
				'54953a79c7d5f87c65560024'
				'549553f0c7d5f87c65560057'
				'5495d572c7d5f87c65560108'
				'549691ffc7d5f87c65560156'
				'5496b885c7d5f87c65560169'
				'5496ec3bc7d5f87c655601b2'
				'54971520c7d5f87c655601e6'
				'5497ff35c7d5f87c6556026c'
				'549840abc7d5f87c655602db'
			]
			
			async.eachSeries ids, eachSeptemberAction, next
		() ->
			console.log 'septemberAction done'
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/test/septemberAction: #{error}"
		res.send error