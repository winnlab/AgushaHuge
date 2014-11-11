_ = require 'underscore'
async = require 'async'
nodemailer = require 'nodemailer'
emailTemplates = require 'email-templates'
mail = nodemailer.mail

app = require '../init/application'

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
	
	cb_html = null

	async.waterfall [
		(next) ->
			emailTemplates "#{templatesDir}", next
		(template, next)->
			template name, data, next
		(html, text, next) ->
			cb_html = html
			
			mailOptions =
				from: "Агуша <contact@agusha.com.ua>"
				to: "#{data.toName} <#{data.to}>"
				subject: data.subject
				text: text
				html: html
			
			transport.sendMail mailOptions, next
		->
			cb cb_html
	], (err) ->
		cb err