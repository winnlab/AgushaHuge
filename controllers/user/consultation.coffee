async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Moneybox = require '../../lib/moneybox'
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
			Model 'Consultation', 'findOne', _id: id, next
		(doc, next) ->
			if doc
				data.consultation = doc

				Model 'Article', 'find', {
					'theme.theme_id': doc.theme.theme_id
				}, next
		(docs, next) ->
			if docs.length > 3
				data.similarArticles = docs
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

			View.render 'user/consultation/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/consultation/index: #{error}"
		res.send error

getDenormalizedData = (obj, user, cb) ->
	async.parallel
		age: (proceed) ->
			return proceed null, null unless obj.age_id
			Model 'Age', 'findById', obj.age_id, '_id  title', proceed
		theme: (proceed) ->
			return proceed null, null unless obj.theme_id
			Model 'Theme', 'findById', obj.theme_id, '_id  name', proceed
	, (err, data) ->
		result =
			author:
				author_id: user?._id
				name: (user?.profile?.first_name or '') + ' ' + (user?.profile?.last_name or '')
			type:
			    name: "Статья от пользователя"
			encyclopedia: false
			closed: false
			active: true
		if data.age
			result.age = [
				_id: obj.age_id
				title: data?.age?.title or ''
				fixture: ''
			]
		if data.theme
			result.theme = [
				_id: obj.theme_id
				name: data.theme.name
			]
		cb err, result

exports.setConsultation = (req, res) ->
	consultation = null
	async.waterfall [
		(next) ->
			getDenormalizedData req.body, req.user, next
		(data, next) ->
			data.name = req.body.name
			data.text = req.body.text
			DocModel = Model 'Consultation'
			doc = new DocModel data
			doc.save next
		(doc, numEffected, next) ->
			consultation = doc
			Moneybox.consultation req.user._id, next
	], (err, doc) ->
		View.ajaxResponse res, err, consultation
