async = require 'async'

View = require './view'
Model = require './model'
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
				return Model 'Category', 'findOne', next, {url_label: category}, '_id', sortOptions
			
			next null
		age: (next) ->
			if age
				return Model 'Age', 'findOne', next, {value: age}, '_id', sortOptions
			
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
	async.waterfall [
		(next) ->
			makeSearchOptions category, age, next
		(searchOptions, next) ->
			Model 'Product', 'find', next, searchOptions
		(docs, next) ->
			Model 'Product', 'populate', callback, docs, 'age category'
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
			
			Model 'Age', 'find', next, {active: true}, null, options
		categories: (next) ->
			options =
				lean: true
			
			Model 'Category', 'find', next, {active: true}, null, options
	}, callback

exports.getAdjacents = (doc, callback) ->
	result = []
	
	async.waterfall [
		(next) ->
			Model 'Product', 'find', next, age: doc.age._id, 'alias image', lean: true
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