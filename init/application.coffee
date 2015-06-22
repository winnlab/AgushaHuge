http = require 'http'

express = require 'express'
async = require 'async'
passport = require 'passport'
roles = require 'roles'
_ = require 'underscore'

cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'express-session'
methodOverride = require 'method-override'
multer = require 'multer'
MongoStore = require('connect-mongo') session
json2xls = require 'json2xls'

Admin = require '../lib/admin'
Ajax = require '../lib/ajax'
Auth = require '../lib/auth'
Image = require '../lib/image'
Logger = require '../lib/logger'
Model = require '../lib/model'
View = require '../lib/view'
Client = require '../controllers/admin/clients'

crypto = require '../utils/crypto'

adminController = require '../controllers/admin'
userController = require '../controllers/user'

locals = require './locals'

jadeOptions =
	layout: false

sessionParams =
	secret: '4159J3v6V4rX6y1O6BN3ASuG2aDN7q'
	store: new MongoStore
		db: 'AgushaHuge'
		expireAfter: 604800000

routes = () ->
	@use userController.Router
	@use '/', userController.Router
	@use '/admin', adminController.Router

configure = () ->
	that = @

	@set 'views', "#{__dirname}/../views"
	@set 'view engine', 'jade'
	@set 'view options', jadeOptions

	@use '/js', express.static "#{__dirname}/../public/js"
	@use '/img', express.static "#{__dirname}/../public/img"
	@use '/css', express.static "#{__dirname}/../public/css"
	@use '/fonts', express.static "#{__dirname}/../public/fonts"
	@use '/doc', express.static "#{__dirname}/../public/doc"
	@use '/dist', express.static "#{__dirname}/../public/dist"
	@use '/robots.txt', (req, res)->
		res.set 'Content-Type', 'text/plain'
		res.send "User-agent: *\nDisallow: /"
	@use '/fs.js', (req, res)->
		res.set 'Content-Type', 'text/plain'
		res.send ''
	
	@use bodyParser limit: '16mb'
	@use methodOverride()

	@use (req, res, next) ->
		dest = req.query?.uploadDir || './public/img/uploads/'

		mMiddleware = multer
			dest: dest
			rename: (fieldname, filename) ->
				return crypto.md5 filename + Date.now()
			onFileUploadComplete: Image.doResize
		mMiddleware req, res, next

	@use View.compiler root: '/views'

	@use json2xls.middleware

	@use cookieParser 'LmAK3VNuA6'
	@use session sessionParams
	@use passport.initialize()
	@use passport.session()
	@use '/admin', Auth.isAuth
	@use '/admin', Auth.isAdmin
	@use View.globals
	@post '/admin/clients/export', Client.export
	@post '/admin/clients/downloadFile', Client.downloadFile

	@use '/admin', (req, res, next) ->
		Ajax.isAjax req, res, next, adminController.layoutPage

errorHandler = () ->
	@use (err, req, res, next) ->
		View.ajaxResponse res, err,
			message: err.message

exports.init = (callback) ->
	exports.express = app = express()
	exports.server = http.Server app

	app.locals = locals

	configure.apply app
	routes.apply app
	errorHandler.apply app

	callback null

exports.listen = (port, callback) ->
	exports.server.listen port, callback
