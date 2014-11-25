async = require 'async'

View = require './view'
Model = require './model'
Logger = require './logger'
Mail = require './mail'

# do we even need this file?

exports.sendMail = (template, options, callback) ->
	Mail.send template, options, callback