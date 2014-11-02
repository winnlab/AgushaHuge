async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Article = require '../../lib/article'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'



exports.findOne = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
	
	alias: req.params.alias

	id = req.params.id
	
	res.locals.params = req.params # req.params is not accessable in middlewares -_- 
	
	async.waterfall [
		(next) ->
			Model 'Consultation', 'findOne', next, _id: id,
		(doc, next) ->
			if doc
				data.consultation = doc

				Model 'Article', 'find', next, {
					'theme.theme_id': doc.theme.theme_id
				}
		(docs, next) ->
			if docs
				data.similarArticles = docs

			View.render 'user/consultation/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/consultation/index: #{error}"
		res.send error