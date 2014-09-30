async = require 'async'
_ = require 'underscore'
moment = require 'moment'
jade = require 'jade'
fs = require 'fs'
zlib = require 'zlib'

Logger = require './logger'
# Cache = require './cache'

string = require '../utils/string'
request = require '../utils/request'

viewDirectory = "#{__dirname}/../views"

compiledFiles = []
compiledClients = []

exports.render = render = (path, res, data) ->
	data = data || {}
	
	_.extend data, res.locals
	
	if res.locals.is_ajax_request is true
		return ajaxResponse res, null, data
	
	# if not compiledFiles[path]
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
	res.locals.current_url = base_url + req.originalUrl
	res.locals.params = req.params
	
	res.locals.moment = moment
	res.locals.is_ajax_request = request.is_ajax_request(req.headers)
	
	next()

loadClient = (name) ->
	filename = "#{viewDirectory}/#{name}.jade"
	
	# if not compiledClients[name]?
	templateCode = fs.readFileSync filename, "utf-8"
	
	options =
		compileDebug: false
		filename: filename
		pretty: false
	
	compiled = jade.compileClient(templateCode, options).toString()
	
	compiledClients[name] =
		source: compiled,
		lastModified: (new Date).toUTCString(),
		gzip: null
	
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
				if options.gzip
					res.setHeader "Content-Encoding", "gzip"
					if container.gzip is null
						zlib.gzip container.source, (err, buffer) ->
							unless err
								container.gzip = buffer
								res.end container.gzip
							else
								next err
					else
						res.end container.gzip
				else
					res.setHeader "Content-Length", (if typeof Buffer isnt "undefined" then Buffer.byteLength(container.source, "utf8") else container.source.length)
					res.end container.source
			catch e
				next e
		else
			next()