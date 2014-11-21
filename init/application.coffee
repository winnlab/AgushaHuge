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

Admin = require '../lib/admin'
Ajax = require '../lib/ajax'
Auth = require '../lib/auth'
Image = require '../lib/image'
Logger = require '../lib/logger'
Model = require '../lib/model'
View = require '../lib/view'

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
	@use '/robots.txt', (req, res)->
		res.set 'Content-Type', 'text/plain'
		res.send "User-agent: *\nDisallow: /"

	@use bodyParser()
	@use methodOverride()

	@use (req, res, next) ->
		dest = req.query?.uploadDir || './public/img/uploads/'

		mMiddleware = multer
			dest: dest
			rename: (fieldname, filename) ->
				return crypto.md5 filename + Date.now()
		mMiddleware req, res, next

	@use View.compiler root: '/views'
	
	@use cookieParser 'LmAK3VNuA6'
	@use session sessionParams
	@use passport.initialize()
	@use passport.session()
	@use '/admin', Auth.isAuth
	@use View.globals

	@use '/admin', (req, res, next) ->
		Ajax.isAjax req, res, next, adminController.layoutPage

exports.init = (callback) ->
	exports.express = app = express()
	exports.server = http.Server app

	app.locals = locals

	configure.apply app
	routes.apply app

	callback null

exports.listen = (port, callback) ->
	exports.server.listen port, callback