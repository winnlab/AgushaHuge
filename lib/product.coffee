async = require 'async'
_ = require 'lodash'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'

translit = require '../utils/translit'

exports.makeSearchOptions = makeSearchOptions = (category, age, callback) ->
	searchOptions =
		active: true
	
	sortOptions =
		lean: true
	
	async.parallel
		category: (next) ->
			if category
				return Model 'ProductCategory', 'findOne', url_label: category, '_id', sortOptions, next
			
			next null
		age: (next) ->
			if age
				return Model 'ProductAge', 'findOne', value: +age, '_id', sortOptions, next
			
			next null
	, (err, results) ->
		if err
			return callback err
		
		if results.category
			searchOptions.category = results.category._id
		
		if results.age
			searchOptions.age = results.age._id
		
		callback null, searchOptions

exports.findAll = (category, age, callback) ->
	# sortOptions =
		# sort:
			# volume: 1
			# assorted: 1
	
	async.waterfall [
		(next) ->
			makeSearchOptions category, age, next
		(searchOptions, next) ->
			Model 'Product', 'find', searchOptions, null, next
		(docs, next) ->
			Model 'Product', 'populate', docs, 'age category', next
		(docs, next) ->
			docs = _.sortBy docs, (doc) ->
				if !doc.category[0]
					return 0
				
				return doc.category[0].position
			
			callback null, docs
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in lib/product/findAll: #{error}"
		View.ajaxResponse res, err

exports.getAgesAndCategories = (callback) ->
	async.parallel {
		ages: (next) ->
			options =
				sort:
					value: 1
				lean: true
			
			Model 'ProductAge', 'find', active: true, null, options, next
		categories: (next) ->
			options =
				lean: true
			
			Model 'ProductCategory', 'find', active: true, null, options, next
	}, callback

exports.getAdjacents = (doc, callback) ->
	result = []
	
	async.waterfall [
		(next) ->
			Model 'Product', 'find', age: doc.age._id, 'alias image', lean: true, next
		(docs) ->
			docsLength = docs.length
			while docsLength--
				product = docs[docsLength]
				if product._id + '' == doc._id + '' # found our product
					index = docsLength
			
			lastIndex = docs.length - 1
			
			if index == 0
				if docs[lastIndex]
					result.push docs[lastIndex]
				
				if docs[index + 1]
					result.push docs[index + 1]
			
			else if index == lastIndex
				if docs[index - 1]
					result.push docs[index - 1]
				
				if docs[0]
					result.push docs[0]
			
			else
				if docs[index - 1]
					result.push docs[index - 1]
				
				if docs[index + 1]
					result.push docs[index + 1]
			
			callback(null, result)
	], callback

exports.makeAlias = makeAlias = (item, callback) ->
	volume = item.getFormattedVolume()
	string = item.title + ' ' + volume.volume + ' ' + volume.postfix
	string = string.replace(RegExp(' +(?= )', 'g'), '') # remove double spaces
	string = string.toLowerCase()
	
	item.alias = translit string
	
	item.save callback

exports.makeAliases = (callback) ->
	async.waterfall [
		(next) ->
			Model 'Product', 'find', next
		(docs) ->
			async.each docs, makeAlias, callback
	], callback