async = require 'async'
_ = require 'lodash'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'
Mail = require './mail'

email = 'hydra0@bigmir.net'

exports.send = (req, res) ->
	async.waterfall [
		(next) ->
			mail_options =
				toName: ''
				to: email
				subject: "Новый отзыв на agusha.com.ua"
			
			options = _.extend mail_options, req.body
			
			Mail.send 'feedback', options, next
		() ->
			View.ajaxResponse res, null, req.body
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/feedback/send: #{error}"
		View.ajaxResponse res, error