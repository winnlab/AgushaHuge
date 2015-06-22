async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'news'
	
	searchOptions =
		active: true
	
	sortOptions =
		lean: true
		sort:
			title: 1
	
	async.waterfall [
		(next) ->
			View.render 'user/news/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/news/index: #{error}"
		res.send error