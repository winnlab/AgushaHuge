http = require 'http'

express = require 'express'
async = require 'async'
passport = require 'passport'
roles = require 'roles'
crypto = require 'crypto'
_ = require 'underscore'

cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'express-session'
methodOverride = require 'method-override' 
multer = require 'multer'
compression = require 'compression'
gzip = require 'connect-gzip'

Admin = require '../lib/admin'
Auth = require '../lib/auth'
Cache = require '../lib/cache'
Logger = require '../lib/logger'
Model = require '../lib/model'
View = require '../lib/view'

admin_controller = require '../controllers/admin'
user_controller = require '../controllers/user'

jadeOptions =
	layout: false

sessionParams =
	secret: '4159J3v6V4rX6y1O6BN3ASuG2aDN7q'

abideOption =
	supported_languages: ['ru']
	default_lang: 'ru',
	translation_directory: 'locale'
	locale_on_url: false

routes = () ->
	@use user_controller.Router
	@use '/', user_controller.Router
	@use '/admin', admin_controller.Router

configure = () ->
	@use (req, res, next) ->
		async.parallel
			consSpec: (callback) ->
				Model 'Consultation', 'find', callback, 
					type: 0
					closed: false
					active: true
			consComm: (callback) ->
				Model 'Consultation', 'find', callback, 
					type: 1
					closed: false
					active: true
					'answers': 
						'$size': 0
		, (err, results) ->
			Logger.log 'info', err if err

			res.locals.consSpec = if results.consSpec is undefined then 'N/A' else results.consSpec.length
			res.locals.consComm = if results.consComm is undefined then 'N/A' else results.consComm.length

			next()


	@set 'views', "#{__dirname}/../views"
	@set 'view engine', 'jade'
	@set 'view options', jadeOptions
	@use compression
		threshold: 2048
	@use gzip.gzip
		matchType: ///js/image/images/image/img///
	@use '/js', express.static "#{__dirname}/../public/js"
	@use '/img', express.static "#{__dirname}/../public/img"
	@use '/attachable', express.static "#{__dirname}/../public/img/admin/attachable"
	@use '/css', express.static "#{__dirname}/../public/css"
	@use '/fonts', express.static "#{__dirname}/../public/fonts"
	@use '/robots.txt', (req, res)->
		res.set 'Content-Type', 'text/plain'
		res.send "User-agent: *\nDisallow: /"

	@use multer {dest: './public/img/'}

	@use Cache.requestCache
	@use bodyParser()
	@use cookieParser 'LmAK3VNuA6'
	@use session sessionParams
	@use passport.initialize()
	@use passport.session()
	@use '/admin', Auth.isAuth
	@use methodOverride()
	@use View.globals

exports.init = (callback) ->
	exports.express = app = express()
	exports.server = http.Server app

	configure.apply app
	routes.apply app

	callback null

exports.listen = (port, callback) ->
	exports.server.listen port, callback