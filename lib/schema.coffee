async = require 'async'
_ = require 'underscore'

Image = require './image'
Logger = require './logger'

genereteCleanupFn - (fields) ->
	return (doc) ->
		iterator = (field, callback) ->
			unless doc[field]
				callback null

			if _.isArray doc[field]
				async.each doc[field], Image.doRemoveImage, callback
			else if _.isString doc[field]
				Image.doRemoveImage doc[field], callback

		if typeof fields is 'string'
			fields = fields.split ' '

		async.each fields, iterator, (err) ->
			if err
				Logger.log 'info', 'Error occured while removing images:', err

exports.init = (Schema, fields) ->
	Shema.post 'remove', genereteCleanupFn fields
