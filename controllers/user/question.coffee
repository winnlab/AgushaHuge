async = require 'async'
_ = require 'lodash'

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
			consultation = Model 'Consultation', 'findOne', null, transliterated: link

			consultation.populate('author.author_id answer.author.author_id').exec next
		(doc, next) ->
			if doc
				data.consultation = doc

				Model 'Article', 'find', next, {
					'theme._id': { $in: _.pluck doc.theme, '_id' },
				}, null, {
					limit: 9
				}
		(docs, next) ->
			if docs.length > 3
				next null, docs
			else
				Model 'Article', 'find', next, {
					'age._id': {
						$in: _.pluck data.consultation.age, '_id'
					},
				}, null, {
					limit: 9,
					sort: 'updated'
				}

		(docs, next) ->
			if docs
				data.similarArticles = docs

			ageIdArr = _.pluck data.consultation.age, '_id'
			Model 'Age', 'findOne', next, {_id: ageIdArr[0]}
		(doc, next) ->

			if doc?.icon?.fixture
				data.consultation.fixture = doc.icon.fixture
			else
				data.consultation.fixture = "/img/user/question/bg.jpg"

			if req.user
				data.user = {
					_id: req.user._id,
					profile: req.user.profile
				}

			View.render 'user/question/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/question/index: #{error}"
		res.send error



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