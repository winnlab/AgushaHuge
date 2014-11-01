
_ = require 'underscore'
async = require 'async'
nodemailer = require 'nodemailer'
emailTemplates = require 'email-templates'
mail = nodemailer.mail

app = require('../init/application')

transportOptions =
	service: "Gmail"
	auth:
		user: "nodesmtp@gmail.com",
		pass: "smtpisverygood11"

transport = nodemailer.createTransport 'SMTP', transportOptions
# transport = nodemailer.createTransport()


templatesDir = "#{__dirname}/../public/views/helpers/email"

exports.send = (name, data, cb) ->
	data = _.extend app.express.locals, data

	async.waterfall [
		(next) ->
			emailTemplates "#{templatesDir}", next
		(template, next)->
			template name, data, next
		(html, text, next) ->
			mailOptions =
				from: "noreply <nodesmtp@gmail.com>"
				to: "#{data.toName} <#{data.to}>"
				subject: data.subject
				text: text
				html: html
			
			transport.sendMail mailOptions, next
		->
			cb null
	], (err) ->
		cb err