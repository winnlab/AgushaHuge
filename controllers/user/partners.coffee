async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'partners'
	
	searchOptions =
		active: true
	
	sortOptions =
		lean: true
		sort:
			title: 1
	
	async.waterfall [
		(next) ->
			Model 'Partner', 'find', searchOptions, '-active -__v', sortOptions, next
		(docs, next) ->
			data.partners = docs
			
			View.render 'user/partners/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/partners/index: #{error}"
		res.send error