_ = require 'underscore'
fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'

objUtils = require '../utils/object.coffee'

class Crud

	constructor: (options) ->
		defaults =
			uploadDir: './public/img/uploads/'
			files: []
		@options = _.extend defaults, options
		@options.filename = __filename

	# The name of query options field
	queryOptions: 'queryOptions'

	# This is the main method of CRUD library.
	# It is check query type and call corresponding function.
	# Arguments to cor. function is req and cb
	request: (req, res) ->
		cb = (err, data) =>
			@result err, data, res

		switch req.method
			when "GET"
				if _.isEmpty(req.params) or not req.params.id
					@_findAll req, cb
				else
					@_findOne req, cb
			when "POST", "PUT"
				@_save req, cb
			when "DELETE"
				@_remove req, cb
			else
				cb 'Error: #{req.method} is not allowed!'

	# This is the data-model wrapper.
	DataEngine: (method, cb, args...) ->
		arr = [@options.modelName]
		arr.push method if method

		params = arr.concat args
		params.push cb

		return Model.apply Model, params

	_getOptions: (query) ->
		if query[@queryOptions] then query[@queryOptions] else {}

	# Check of existing "fields" attribute in query options and in case if
	# this field is exist, the method will remove it from options.
	_parseFields: (query) ->
		options = @_getOptions(query)

		fields = if options.fields then options.fields else null

		if options.fields
			delete options.fields

		return fields

	# Check of existing "options" attribute in query and in case if
	# this attribute is exist, it will remove "options" from query.
	_parseOptions: (query) ->
		options = @_getOptions(query)

		if query[@queryOptions]
			delete query[@queryOptions]

		return options

	_findAll: (req, cb) ->
		query = req.query		
		fields = @_parseFields req.query
		options = @_parseOptions req.query
		@findAll query, cb, options, fields

	findAll: (query, cb, options = {}, fields = null) ->
		@DataEngine 'find', cb, query, fields, options

	_findOne: (req, cb) ->
		id = req.params.id or req.query.id
		fields = @_parseFields req.query
		options = @_parseOptions req.query
		@findOne id, cb, options, fields

	findOne: (id, cb, options = {}, fields = null) ->
		@DataEngine 'findById', cb, id, fields, options

	# Depends of id property this method call "add" or "update" functions
	_save: (req, cb) ->
		id = req.body._id or req.params.id

		if id
			delete req.body._id if req.body._id
			@update id, req.body, cb
		else
			@add req.body, cb

	add: (data, cb) ->
		next = (err, data) ->
			# cb err, _id: data?._id
			cb err, data
		DocModel = @DataEngine()
		doc = new DocModel()

		for own field, value of data
			objUtils.handleProperty doc, field, value

		doc.save next

	update: (id, data, cb) ->
		async.waterfall [
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				for own field, value of data
					objUtils.handleProperty doc, field, value
				doc.save cb
		], cb


	_remove: (req, cb) ->
		id = req.params.id || req.body._id || req.body.id

		if id
			@remove id, cb
		else
			cb 'There no "id" param in a query'

	remove: (id, cb) ->
		async.waterfall [
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				proceed = (err) ->
					next err, doc
				@_removeDocFiles doc, proceed
			(doc) ->
				doc.remove cb
		], cb

	# File request function
	fileRequest: (req, res) ->
		cb = (err, data) =>
			@result err, data, res

		switch req.method
			when "POST"
				@_upload req, cb
			when "DELETE"
				@_removeFile req, cb
			else
				cb 'Error: #{req.method} is not allowed!'

	# return file name if it is string, or link to the document array
	_getUploadedFile: (doc, opt) ->
		if opt.parent
			return doc[opt.parent][opt.name]
		else
			return doc[opt.name]

	_getFileOpts: (fieldName) ->
		return _.find @options.files, (file) ->
			return file.name is fieldName

	_upload: (req, cb) ->
		id = req.body.id or req.body._id
		fieldName = req.body.name.replace /[\[\]]/g, ''
		fileOpts = @_getFileOpts fieldName

		if not fileOpts
			return cb 'Ошибка: неизвестное название свойства документа'

		if fileOpts.type is 'string'
			file = req.files?[fieldName]?.name
		else
			file = req.files?["#{fieldName}[]"]

		if id and fileOpts and file
			async.waterfall [
				(next) =>
					@findOne id, next
				(doc, next) =>
					uploadedFile = @_getUploadedFile doc, fileOpts

					if fileOpts.replace and uploadedFile
						@removeFile uploadedFile, (err) ->
							next err, doc
					else
						next null, doc
				(doc) =>
					@upload doc, file, fileOpts, cb
			], cb

		else
			cb 'Ошибка. Не передано поле "id" или "fieldName"'

	_setDocFiles: (doc, file, fileOpts) ->
		if fileOpts.type is 'string'
			if fileOpts.parent
				doc[fileOpts.parent][fileOpts.name] = file
			else
				objUtils.handleProperty doc, fileOpts.name, file
				# doc[fileOpts.name] = file
		else
			target = @_getUploadedFile doc, fileOpts
			unless typeof file is 'number'
				if _.isArray file
					_.each file, (f) ->
						target.push f.name if f.name
				else
					target.push file.name if file.name
			else
				target.splice file, 1

	upload: (doc, file, fileOpts, cb) ->
		@_setDocFiles doc, file, fileOpts

		doc.save (err, doc) ->
			cb err if err
			data = {}
			data[fileOpts.name] = file

			if doc.__v
				data['__v'] = doc.__v

			cb null, data

	# parse req and do stuff depends of fieldName
	_removeFile: (req, cb) ->
		id = req.body.id or req.body._id
		fieldName = req.body.name
		fileName = req.body.sourceName
		fileOpts = @_getFileOpts fieldName

		async.waterfall [
			(next) ->
				if id and fileOpts
					next null
				else
					next 'Error. there are unknown "id" or "fieldName"'
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				fileName = fileName or @_getUploadedFile doc, fileOpts
				unless typeof fileName is 'string'
					next 'Error. You try remove unknown filename'
				proceed = (err) ->
					next err, doc
				@removeFile fileName, proceed
			(doc) =>
				if fileOpts.type == 'string'
					@_setDocFiles doc, null, fileOpts
				else
					index = (@_getUploadedFile doc, fileOpts).indexOf fileName
					@_setDocFiles doc, index, fileOpts
				doc.save cb
		], cb

	_removeFiles: (files = [], cb) ->
		async.each files, (file, proceed) =>
			@removeFile file, proceed
		, cb

	removeFile: (file, cb) ->
		if not file
			return cb null
		fs.unlink "#{@options.uploadDir}#{file}", (err) ->
			if err is null or err.code is 'ENOENT'
				cb null
			else
				cb err

	# remove all document files
	_removeDocFiles: (doc, cb) ->
		async.each @options.files, (fileOpts, proceed) =>
			uploadedFile = @_getUploadedFile doc, fileOpts
			if typeof uploadedFile is 'string'
				@removeFile uploadedFile, proceed
			else
				@_removeFiles uploadedFile, proceed
		, cb

	###
		Sending result to client
	###
	result: (err, data, res) ->
		View.ajaxResponse res, err, data

module.exports = Crud