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
	
	View.render 'user/question/index', res, data



exports.findOne = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
	
	alias: req.params.alias

	id = req.params.id
	
	res.locals.params = req.params # req.params is not accessible in middlewares -_-
	
	async.waterfall [
		(next) ->
			consultation = Model 'Consultation', 'findOne', null, _id: id

			consultation.populate('author').exec next
		(doc, next) ->
			if doc
				data.consultation = doc

				Model 'Article', 'find', next, {
					'theme._id': {
						$in: _.pluck doc.theme, '_id'
					}
				}
		(docs, next) ->
			if docs
				data.similarArticles = docs

			View.render 'user/question/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/question/index: #{error}"
		res.send error