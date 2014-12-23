async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'


tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

getData = (cb) ->
	async.parallel
		ages: (proceed) ->
			Model 'Age', 'find', {"active" : true}, null, {sort: {'position': 1}}, proceed
		themes: (proceed) ->
			Model 'Theme', 'find', {"active" : true}, proceed
		articles: (proceed) ->
			consultation = Model 'Consultation', 'find', {"active" : true}, null
			consultation.populate({
				path: 'author.author_id'
				select: 'image created_at'
				model: 'Client'
			}).exec proceed
	, cb

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'

	res.locals.params = req.params # req.params is not accessable in middlewares -_-

	async.waterfall [
		(next) ->
			getData next
		(results) ->
			_.extend data, results
			View.render 'user/specialist/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/encyclopedia/index: #{error}"
		res.send error
