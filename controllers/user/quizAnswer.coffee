async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'



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
		result.answer[answerKey].percent = answerItem.score * 100 / sum

	cb null, result