async = require 'async'
_ = require 'lodash'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'
Mail = require './mail'

emails = [
	'dkirpa@gmail.com'
	'contact@agusha.com.ua'
	'omkovalova@gmail.com'
	'olga.kovaleva@pepsico.com'
]

sendEmail = (res, email, data, callback) ->
	mail_options =
		toName: ''
		to: email
		subject: "Новый отзыв на agusha.com.ua"
	
	options = _.extend mail_options, data
	
	Mail.send 'feedback', options, callback

exports.send = (req, res) ->
	async.waterfall [
		(next) ->
			async.eachSeries emails, (email, callback) ->
				sendEmail res, email, req.body, callback
			, next
		() ->
			View.ajaxResponse res, null, req.body
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/feedback/send: #{error}"
		View.ajaxResponse res, error