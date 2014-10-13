async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
	
	async.waterfall [
		(next) ->
			searchOptions =
				active: true
			
			sortOptions =
				lean: true
				sort:
					value: 1
				limit: 6
			
			Model 'Age', 'find', next, searchOptions, 'title value icon desc', sortOptions
		(docs, next) ->
			data.ages = docs
			
			View.render 'user/encyclopedia/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/encyclopedia/index: #{error}"
		res.send error