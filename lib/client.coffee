async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'
Mail = require './mail'

exports.sendMail = (client, template, subject, callback) ->
	options =
		subject: subject
		login: client.login
		email: client.email
	
	Mail.send template, options, callback