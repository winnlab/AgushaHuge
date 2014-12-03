async = require 'async'
_ = require 'underscore'
jade = require 'jade'
fs = require 'fs'

Model = require './model'
Logger = require './logger'
# Cache = require './cache'

string = require '../utils/string'
request = require '../utils/request'

viewDirectory = "#{__dirname}/../public/views"

compiledFiles = []
compiledClients = []

exports.render = render = (path, res, data) ->
	data = data || {}
	
	_.extend data, res.locals

	if res.locals.is_ajax_request is true
		return ajaxResponse res, null, data

	if not compiledFiles[path]
		options =
			compileDebug: false
			pretty: false

		compiledFiles[path] = jade.compileFile "#{viewDirectory}/#{path}.jade", options

	html = compiledFiles[path] data

	res.send html

exports.ajaxResponse = ajaxResponse = (res, err, data) ->
	data =
		err: (if err then err else false)
		data: (if data then data else null)

	res.status if err then 500 else 200

	res.send data

exports.message = message = (success, message, res) ->
	data = {
		success
		message
	}

	render 'admin/board/message', res, data

exports.error = (err, res) ->
	message false, err.message or err, res

exports.clientError = (err, res) ->
	data =
		success: false
		error: err.message
		code: err.code

	render 'user/main/error/index', res, data

exports.clientSuccess = (data, res)->
	data =
		success: true
		message: data

	res.send data

exports.clientFail = (err, res)->
	res.status 500

	data =
		success: false
		message: err

	res.send data

exports.globals = (req, res, next)->
	if req.user
		res.locals.user = req.user

	res.locals.base_url = base_url = 'http://' + req.headers.host
	res.locals.current_url = base_url + req._parsedUrl.pathname
	res.locals.path_name = req._parsedUrl.pathname.split('/')[1]

	moment = require 'moment'
	moment.locale 'ru'
	res.locals.moment = moment

	res.locals.is_ajax_request = request.is_ajax_request(req.headers)
	res.locals.strip_tags = string.strip_tags
	
	async.waterfall [
		(next2) ->
			Model 'Client', 'count', next2
		(count) ->
			res.locals.user_count = _.chars count + ''
			
			next()
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/moneybox/index: #{error}"
		next error

loadClient = (name) ->
	filename = "#{viewDirectory}/#{name}.jade"

	if not compiledClients[name]?
		templateCode = fs.readFileSync filename, "utf-8"

		options =
			compileDebug: false
			filename: filename
			pretty: false

		compiled = jade.compileClient(templateCode, options).toString()

		compiledClients[name] =
			source: compiled,
			lastModified: (new Date).toUTCString()

	compiledClients[name]

exports.compiler = (options) ->
	options = options or {}
	options.root = options.root or "/"
	options.root = "/" + options.root.replace(/^\//, "")
	options.root = options.root.replace(/\/$/, "") + "/"
	rootExp = new RegExp("^" + string.escape(options.root))

	(req, res, next) ->
		if req.method isnt "GET" and req.method isnt "HEAD"
			return next()

		if not options.root or req.url.substr(0, options.root.length) is options.root
			template = req.url.replace(rootExp, "")

			try
				# context = new TemplateContext
				# container = context.load(template)

				container = loadClient template

				res.setHeader "Content-Type", "application/x-javascript; charset=utf-8"
				res.setHeader "Last-Modified", container.lastModified
				res.setHeader "Content-Length", (if typeof Buffer isnt "undefined" then Buffer.byteLength(container.source, "utf8") else container.source.length)
				res.end container.source
			catch e
				next e
		else
			next()
