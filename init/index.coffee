async = require 'async'
_ = require 'underscore'
_.str = require 'underscore.string'

Database = require './database'
Migrate = require './migrate'
Application = require './application'
AuthStartegies = require './auth'
ModelPreloader = require './mpload'
Roles = require './roles'

Logger = require '../lib/logger'
Notifier = require '../lib/notifier'
Image = require '../lib/image'
Product = require '../lib/product'

config = require '../config.json'

_.mixin _.str.exports()

async.waterfall [
	(next) ->
		Logger.log 'info', 'Pre initialization succeeded'
		Logger.init next
	(next) ->
		Logger.log 'info', 'Logger is initializated'

		ModelPreloader "#{process.cwd()}/models/", next
	(next) ->
		Logger.log 'info', 'Models are preloaded'

		Migrate.init next
	(next) ->
		Logger.log 'info', 'Migrate is initializated'
		
		Roles.init next
	(next) ->
		Logger.log 'info', 'Roles are created'
		
		Image.checkDirectories next
	(next) ->
		Logger.log 'info', 'Image directories are checked'
		
		Product.makeAliases next
	(next) ->
		Logger.log 'info', 'Product aliases are recreated'
		
		Application.init next
	(next) ->
		Logger.log 'info', "Application is initializated"

		AuthStartegies.init next
	(next) ->
		Logger.log 'info', 'Auth is initializated'
		
		Application.listen config.port, next
	(next) ->
		Logger.log 'info', "Application is binded to #{config.port}"
], (err) ->
	Logger.error 'Init error: ', err