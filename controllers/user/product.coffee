async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Product = require '../../lib/product'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'products'
	
	async.waterfall [
		(next) ->
			product = Model 'Product', 'findOne', null, alias: req.params.alias
			
			product.populate('age certificate').exec next
		(doc, next) ->
			if !doc
				return next new Error 'Something went wrong - product not found'
			
			volume = doc.getFormattedVolume()
			
			doc = doc.toObject()
			
			doc.volume = volume
			
			data.product = doc
			
			data.breadcrumbs.push
				parent_id: 'products'
				title: data.product.title
			
			Product.getAdjacents doc, next
		(docs) ->
			data.adjacents = docs
			
			View.render 'user/product/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/product/index: #{error}"
		res.send error