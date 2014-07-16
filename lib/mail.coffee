async = require 'async'
nodemailer = require 'nodemailer'
emailTemplates = require 'email-templates'
mail = nodemailer.mail

templatesDir = "#{__dirname}/../views/helpers/email"

exports.send = (name, data, cb) ->
	async.waterfall [
		(next) ->
			emailTemplates "#{templatesDir}", next
		(template, next)->
			template name, data, next
		(html, text, next) ->
			transportOptions =
				service: "Gmail"
				auth:
					user: "nodesmtp@gmail.com",
					pass: "smtpisverygood11"
			
			transport = nodemailer.createTransport 'SMTP', transportOptions
			
			mailOptions =
				from: "noreply <noreply@winnlab.com>"
				to: "#{data.login} <#{data.email}>"
				subject: data.subject
				text: text
				html: html
			
			transport.sendMail mailOptions, next
		->
			cb null
	], (err) ->
		cb err