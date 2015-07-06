async = require 'async'
_ = require 'lodash'

Article = require '../../lib/article'
View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'



exports.findOne = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'
		alias: req.params.alias

	link = req.params.id

	res.locals.params = req.params # req.params is not accessible in middlewares -_-

	async.waterfall [
		(next) ->
			consultation = Model 'Consultation', 'findOne', '-__v', transliterated: link
			consultation.select watchers: $elemMatch: $in: [req?.user?._id]
			consultation.populate('author.author_id answer.author.author_id').exec next
		(doc, next) ->
			return next 404 unless doc
			data.consultation = doc
			Article.similarArticles req?.user?._id,
				_.pluck(doc.theme, '_id'),
				_.pluck(data.consultation.age, '_id'),
				next
		(docs, next) ->
			if docs
				data.similarArticles = docs

			ageIdArr = _.pluck data.consultation.age, '_id'
			Model 'Age', 'findOne', next, {_id: ageIdArr[0]}
		(doc, next) ->

			if doc?.icon?.fixture
				data.background = doc.icon.fixture
			else
				data.background = "/img/user/question/bg.jpg"

			if req.user
				data.user = {
					_id: req.user._id,
					profile: req.user.profile
				}

			View.render 'user/question/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/question/index: #{error}"
		View.ajaxResponse res, err



exports.sendAnswer = (req, res) ->
	data = req.body
	userId = req.user?._id
	result = {}

	if userId
		async.waterfall [
			(next) ->
				if data._id
					Model 'Consultation', 'findOne', next, _id: data._id
				else
					next 404
			(doc, next) ->
				if doc
					doc.answer.push data.answer

					doc.save next
				else
					next 404
		], (err, doc) ->
			View.ajaxResponse res, err, doc
	else
		View.ajaxResponse res, 403, 'Unauthorized user'
