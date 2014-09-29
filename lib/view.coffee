async = require 'async'
_ = require 'underscore'
moment = require 'moment'
jade = require 'jade'

Logger = require './logger'
# Cache = require './cache'

viewDirectory = "#{__dirname}/../views"

compiledFiles = []

exports.render = render = (path, res, data) ->
	data = data || {}
	
	_.extend data, res.locals
	
	# if res.locals.is_ajax_request is true
		# return ajaxResponse res, null, data
	
	# html = application.ectRenderer.render path += '/index', data
		
	if not compiledFiles[path]
		options =
			compileDebug: false
			pretty: false
		
		compiledFiles[path] = jade.compileFile "#{viewDirectory}/#{path}.jade", options
	
	html = compiledFiles[path] data
	
	res.send html

exports.ajaxResponse = (res, err, data) ->
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
	
	next()