async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
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
			if docs
				data.similarArticles = docs

			View.render 'user/consultation/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/consultation/index: #{error}"
		res.send error

getDenormalizedData = (obj, cb) ->
	async.parallel
		age: (proceed) ->
			Model 'Age', 'findOne', {_id: obj.age_id}, '_id  title', proceed
		theme: (proceed) ->
			Model 'Theme', 'findOne', {_id: obj.theme_id}, '_id  name', proceed
	, (err, data) ->
		result =
			author:
				author_id: obj?.user?._id
				name: obj?.user?.profile?.first_name + ' ' + obj?.user?.profile?.last_name
			age:
				age_id: obj.age_id
				title: data.age.title
				fixture: ''
			theme:
				theme_id: obj.theme_id
				name: data.theme.name
			type:
			    name: "Статья от пользователя"
			encyclopedia: false
			closed: false
			active: true
			answer: []
		cb err, result

exports.setConsultation = (req, res) ->
	async.waterfall [
		(next) ->
			getDenormalizedData req.body, next
		(data, next) ->
			data.name = req.body.name
			data.text = req.body.text
			DocModel = Model.apply Model, ['Consultation']
			doc = new DocModel data
			doc.save next
	], (err, doc) ->
		View.ajaxResponse res, err, doc
