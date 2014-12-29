_ = require 'underscore'
async = require 'async'
nodemailer = require 'nodemailer'
emailTemplates = require 'email-templates'
mail = nodemailer.mail

app = require '../init/application'

# transportOptions =
	# host: 'mx1.mirohost.net'
	# auth:
		# user: 'contact@agusha.com.ua',
		# pass: 'aHErkvZu'

# transportOptions =
	# host: 's02.atomsmtp.com'
	# port: '2525'
	# auth:
		# user: 'contact@agusha.com.ua'
		# pass: 'DeNgYYmNeAp2ScK'

transportOptions =
	host: '0.0.0.0'
	port: '25'

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
			cb null, cb_html
	], (err) ->
		cb err