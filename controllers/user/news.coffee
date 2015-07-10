async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'
News = require '../../lib/news'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

getNews = (req, cb, options = {}) ->
	docsCount = 24
	if options.lastId
		anchorId = options.lastId
		delete options.lastId

	query =
		active: true
		hideOnMain: false

	options.sort =
		position: -1

	options.lean = true

	Model 'News', 'findPaginated', query, '_id position', options, (err, docs) ->
		News.getArticlesData req?.user?._id, {
			_id: $in: _.pluck docs.documents, '_id'
		}, (err, articles) ->
			docs.documents = articles
			cb err, docs
	, docsCount, anchorId

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'news'

	async.waterfall [
		(next) ->
			getNews req, next
		(docs) ->
			data.articles = docs

			View.render 'user/news/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/news/index: #{error}"
		res.send error

exports.news = (req, res) ->
	query = _.pick req.query, 'lastId', 'nestedAnchor', 'sort'
	getNews req, (err, docs) ->
		res.json docs
	, query

exports.findOne = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'news'
		news: true

	alias: req.params.alias

	link = req.params.id

	res.locals.params = req.params # req.params is not accessable in middlewares -_-

	async.waterfall [
		(next) ->
			Model 'News', 'findOne', transliterated: link, null, {lean: true}, next
		(doc, next) ->
			console.log doc._id
			if doc
				next null, doc
			else
				next 404
		(doc, next) ->
			data.article = doc

			Model 'Gallery', 'findOne', article_id: data.article._id, next

		(doc, next) ->

			console.log doc

			if doc
				data.article.gallery = doc

			News.similarArticles req?.user?._id or null,
				_.pluck(data.article.theme, '_id'),
				_.pluck(data.article.age, '_id'),
				next,
				data.article._id

		(docs, next) ->
			data.similarArticles = if docs? then docs else []

			if req?.user?._id
				data.user = {
					_id: req.user._id,
					profile: req.user.profile
				}

			View.render 'user/article/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/article/index: #{error}"
		res.send error
