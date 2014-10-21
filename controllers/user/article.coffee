async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Article = require '../../lib/article'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
	
	alias: req.params.alias
	
	async.waterfall [
		(next) ->
			# product = Model 'Product', 'findOne', null, alias: alias
			
			# product.populate('age certificate').exec next
		# (doc, next) ->
			# data.article = doc
			
			View.render 'user/article/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/article/index: #{error}"
		res.send error

exports.findAll = (req, res) ->
	data = {}
	
	async.waterfall [
		(next) ->
			Article.findAll req.body.age, req.body.theme, next
		(docs, next) ->
			data.articles = docs
			
			View.ajaxResponse res, null, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/article/findAll: #{error}"
		View.ajaxResponse res, err