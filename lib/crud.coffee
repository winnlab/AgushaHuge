_ = require 'lodash'
fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'

objUtils = require '../utils/object.coffee'
hprop = objUtils.handleProperty

errorMsg =
	noProperty: 'Denormalized object property `property` should be non-empty string'
	noTargets: 'Denormalized object should have array of denormalizedIn'
	noModelName: 'Denormalized object target should have non-empty string as `model` property'
	noFileName: 'File with denormalizedIn array have no name.'

class Crud

	constructor: (options) ->
		defaults =
			uploadDir: './public/img/uploads/'
			files: []
			###
				`denormalized` structure:
				[
					property: String - Property which should be saved in denormalizedIn
					denormalizedIn: Array - Array of denormalizedIn data
					_id: String - OPTIONAL - Property which will be considered as ID.
											 Could be equal to `property` (to use it as ID)
								  DEFAULT: '_id'
					[
						model: String - Name of denormalizedIn model (for mongoose)
						path: String - Path to object or array where denormalized data stored.
									   Could be empty string.
						multiple: Boolean - If true - CRUD will condider that denormalized data is
											is stored in array of objects (and add .$. to update queries)
						property: String - OPTIONAL - Name under which property will be stored in target object
										   DEFAULT: Equals to parent's object `property`
						_id: String - OPTIONAL - Target property which will be used for find objects to update.
									  DEFAULT: - equals to parent's object `_id`
					]
				]

			###
			denormalized: []
		@options = _.extend defaults, options
		@options.filename = __filename

		@_checkDenormalizedSettings()
		@_checkDenormalizedFilesSettings()

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
			cb err, _id: data?._id
		DocModel = @DataEngine()
		doc = new DocModel()

		for own field, value of data
			hprop doc, field, value

		doc.save next

	update: (id, data, cb) ->
		oldVals = []
		for item in @options.denormalized
			oldVals[item.property] = null

		async.waterfall [
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				for item in @options.denormalized
					value = hprop doc, item.property
					hprop oldVals, item.property, value

				for own field, value of data
					hprop doc, field, value

				doc.save if @options.denormalized.length then next else cb
			(doc) =>
				@_updateDenormalized oldVals, doc, cb
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
	_getUploadedFile: (doc, name) ->
		hprop doc, name

	_getFileOpts: (fieldName) ->
		return _.find @options.files, (file) ->
			return file.name is fieldName

	_upload: (req, cb) ->
		id = req.body.id or req.body._id
		nestedId = req.body.nestedId

		fieldName = req.body.name.replace /[\[\]]/g, ''
		fileOpts = @_getFileOpts fieldName

		if not fileOpts
			return cb 'Ошибка: файл для загрузки не передан или попытка загрузить изображение в не разрешенное свойство документа.'

		if fileOpts.type is 'string'
			file = req.files?[fieldName]?.name
		else
			file = req.files?["#{fieldName}[]"]

		if id and fileOpts and file
			async.waterfall [
				(next) =>
					@findOne id, next
				(doc, next) =>
					uploadedFile = @_getUploadedFile doc, fileOpts.name

					if prop and propId
						

					if fileOpts.replace and uploadedFile
						@removeFile uploadedFile, (err) ->
							next err, doc
					else
						next null, doc
				(doc) =>
					@upload doc, file, fileOpts, nestedId, cb
			], cb

		else
			cb 'Ошибка. Не передано поле "id" или "fieldName"'

	_setDocFiles: (doc, file, fileOpts, propId) ->
		if fileOpts.nested
			if not propId
				throw new Error("Received no property ID while trying ti update nested image #{fileOpts.type} '#{fileOpts.name}'")
				propName = fileOpts.replace /$/, propId
		else
			propName = fileOpts.name

		if fileOpts.type is 'string'
			hprop doc, propName, file
		else
			target = @_getUploadedFile doc, propName
			unless typeof file is 'number'
				if _.isArray file
					_.each file, (f) ->
						target.push f.name if f.name
				else
					target.push file.name if file.name
			else
				target.splice file, 1

	upload: (doc, file, fileOpts, nestedId, cb) ->
		if not cb and typeof nestedId is 'function'
			cb = nestedId
			nestedId = null

		@_setDocFiles doc, file, fileOpts

		oldVals = []
		for item in fileOpts.denormalizedIn
			value = hprop doc, item.property
			hprop oldVals, item.property, value

		doc.save (err, doc) =>
			return cb err if err

			data = {}
			data[fileOpts.name] = file

			if doc.__v
				data['__v'] = doc.__v

			if @options.denormalizedFiles.length
				return @_updateDenormalizedFiles oldVals, doc, data, cb

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
					
			(next) =>
				if not id or not fileOpts
					return next 'Ошибка: неизвестно поле "id" или "fieldName" файла.'
				@DataEngine 'findById', next, id
			(doc, next) =>
				fileName = fileName or @_getUploadedFile doc, fileOpts.name
				unless typeof fileName is 'string'
					next 'Ошибка: попытка удалить неизвестный файл'

				@removeFile fileName, (err) ->
					next err, doc
			(doc) =>
				if fileOpts.type == 'string'
					@_setDocFiles doc, null, fileOpts
				else
					index = (@_getUploadedFile doc, fileOpts.name).indexOf fileName
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
			uploadedFile = @_getUploadedFile doc, fileOpts.name
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

	###
		Denormalization processing
	###
	_updateDenormalizedFiles: (olds, doc, arg, cb) ->
		@_processDenormalizedArray 'denormalizedFiles', olds, doc, arg, cb

	_updateDenormalized: (olds, doc, cb) ->
		@_processDenormalizedArray 'denormalized', olds, doc, cb

	_processDenormalizedArray: (name, olds, doc, arg..., cb) ->
		news = []
		for item in @options[name]
			value = hprop doc, item.property
			hprop news, item.property, value

		ifChanged = (item, next) =>
			if hprop(olds, item.property) isnt hprop(news, item.property)
				@_processDenormalization item, doc, next
			else
				next()

		async.each @options[name], ifChanged, (err) ->
			cb err, arg[0] or doc

	_processDenormalization: (item, doc, next) ->
		processTarget = (target, next) ->
			whereProp = ''
			whatProp = ''

			if target.path
				whereProp = whatProp = "#{target.path}."
				if target.multiple
					whatProp += '$.'

			whereProp += target._id
			whatProp += target.property

			where = {}
			what = {}
			where[whereProp] = hprop doc, item._id

			what[whatProp] = hprop doc, item.property

			Model target.model, 'update', where, what, multi: true, next

		async.each item.denormalizedIn, processTarget, next

	_checkDenormalizedSettings: () ->
		for item in @options.denormalized
			@_checkString item.property, errorMsg.noProperty
			@_checkArray item.denormalizedIn, errorMsg.noTargets
			@_ensureString item, '_id', '_id'
			for target in item.denormalizedIn
				@_checkString target.model, errorMsg.noModelName
				@_ensureString target, 'path', ''
				@_ensureString target, 'property', item.property
				@_ensureString target, '_id', item._id

	_checkDenormalizedFilesSettings: () ->
		@options.denormalizedFiles = _.filter @options.files, (item) ->
			_.isArray item.denormalizedIn

		for item in @options.denormalizedFiles
			@_checkString item.name, errorMsg.noFileName
			@_ensureString item, 'property', item.name
			@_ensureString item, '_id', '_id'
			for target in item.denormalizedIn
				@_checkString target.model, errorMsg.noModelName
				@_ensureString target, 'path', ''
				@_ensureString target, 'property', item.property
				@_ensureString target, '_id', item._id

	_checkString: (val, msg) ->
		res = typeof val is 'string' and val.length isnt 0

		throw new Error msg if msg and not res

		return res

	_ensureString: (obj, prop, value) ->
		obj[prop] = value unless @_checkString obj[prop]

	_checkArray: (val, msg) ->
		unless _.isArray(val) and val.length isnt 0
			throw new Error msg

module.exports = Crud