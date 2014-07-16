async = require 'async'
_ = require 'underscore'
moment = require 'moment'

Logger = require './logger'
Cache = require './cache'

exports.render = render = (name, res, data, cacheId) ->
	data or= {}

	async.parallel [
		(next) -> # cache
			if not cacheId
				return next()

			Cache.put name, data, cacheId, res.locals, next
		(next) -> # view
			res.render name, data, next
	], (err, results)->
		if err
			Logger.log 'error', 'Error in View.render:', err
			res.send '404_OR_500_PAGE_SHOULD_BE_HERE_SOMETIMES_LATER'

			node_env = process.env.NODE_ENV || 'development'
			if node_env is 'development'
				console.log err
				throw err
		else
			res.send results[1]

exports.renderWithSession = (req, res, path, data) ->
	data = data || {}
	
	if req.session.err?
		data.err = req.session.err
		delete req.session.err
	
	render path, res, data

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
	res.locals.defLang = 'ru'
	res.locals.lang = req.lang

	if req.user
		res.locals.euser = req.user
		res.locals.user = req.user

	res.locals.moment = moment

	next()