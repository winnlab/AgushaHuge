async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
	
	alias: req.params.alias
	
	res.locals.params = req.params # req.params is not accessable in middlewares -_- 
	
	async.waterfall [
		(next) ->
			# product = Model 'Product', 'findOne', null, alias: alias
			
			# product.populate('age certificate').exec next
		# (doc, next) ->
			# data.article = doc
			
			View.render 'user/poll/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/poll/index: #{error}"
		res.send error