async = require 'async'
_ = require 'lodash'

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
	
	res.locals.params = req.params # req.params is not accessable in middlewares -_- 
	
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

exports.findOne = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
	
	alias: req.params.alias

	id = req.params.id
	
	res.locals.params = req.params # req.params is not accessable in middlewares -_- 
	
	async.waterfall [
		(next) ->
			Model 'Article', 'findOne', next, _id: id, null, {lean: true}
		(doc, next) ->
			if doc.is_quiz
				countStatistics doc, next
			else
				next null, doc
		(doc, next) ->
			if doc
				data.article = doc

				Model 'Article', 'find', next, {
					_id: {$ne: doc._id},
					'theme._id': {
						$in: _.pluck doc.theme, '_id'
					}
				}
		(docs, next) ->
			if docs
				data.similarArticles = docs

			View.render 'user/article/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/article/index: #{error}"
		res.send error



exports.saveAnswer = (req, res) ->

	data = req.body
	result = {}

	async.waterfall [
		(next) ->
			Model 'QuizAnswer', 'create', next, data
		(doc, next) ->
			Model 'Article', 'update', next, {
				_id: data.article,
				'answer._id': data.answer
			}, {
				$inc: {
					'answer.$.score': 1
				}
			}
		(doc, status, next) ->
			Model 'Article', 'findOne', next, _id: data.article, null, {lean: true}
		(doc, next) ->
			countStatistics doc, next		
	], (err, doc) ->
		View.ajaxResponse res, err, doc		



countStatistics = (result, cb) ->
	sum = 0

	_.each result.answer, (answer) ->
		sum += answer.score

	for answerItem, answerKey in result.answer
		percent = answerItem.score * 100 / sum
		result.answer[answerKey].percent = percent.toFixed()

	cb null, result