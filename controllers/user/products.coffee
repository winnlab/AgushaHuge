async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Product = require '../../lib/product'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'products'
	
	async.waterfall [
		(next) ->
			Product.findAll req.params.category, req.params.age, next
		(docs, next) ->
			data.products = docs
			
			Product.getAgesAndCategories next
		(results) ->
			data.ages = results.ages
			data.categories = results.categories
			
			_.each data.products, (item, key, list)->
				volume = item.getFormattedVolume()
				list[key] = item.toObject()
				list[key].volume = volume
			
			View.render 'user/products/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/products/index: #{error}"
		res.send error

exports.findAll = (req, res) ->
	data = {}
	
	async.waterfall [
		(next) ->
			Product.findAll req.body.category, req.body.age, next
		(docs, next) ->
			data.products = docs
			
			_.each data.products, (item, key, list)->
				volume = item.getFormattedVolume()
				list[key] = item.toObject()
				list[key].volume = volume

			View.ajaxResponse res, null, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/products/findAll: #{error}"
		View.ajaxResponse res, err