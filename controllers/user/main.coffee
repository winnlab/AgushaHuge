_ = require 'lodash'
async = require 'async'

Model = require '../../lib/mongooseTransport'

View = require '../../lib/view'

getSubscriptions = (userId, cb) ->
	async.waterfall [
		(next) ->
			Model 'Subscription', 'find', { client_id: userId }, next
		(docs, next) ->
			Model 'Article', 'find', { 'theme._id': { $in: _.pluck(docs, 'theme_id') } }, next
	], cb

getFeed = (user, data, cb) ->
	unless user and user._id
		_.extend data, { themeSubs: [], consultations: [] }
		return cb null

	async.parallel {
		themeSubs: (proceed) ->
			getSubscriptions user._id, proceed
		consultations: (proceed) ->
			Model 'Consultation', 'find', { 'author.author_id': user._id }, proceed
	}, (err, results) ->
		_.extend data, results if results
		cb err

getArticles = (cb, options = {}) ->
	docsCount = 24
	if options.lastId
		anchorId = options.lastId
		delete options.lastId
	if options?.age?._id and options?.theme?._id
		query =
			active: true
			'age._id': options.age._id
			'theme._id': options.theme._id
	else
		query =
			active: true
			hideOnMain: false
	options.sort =
		position: -1

	Model 'Article', 'findPaginated', query, null, options, cb, docsCount, anchorId

exports.index = (req, res) ->
	data =
		breadcrumbs: [
			title: if req.user and req.user.profile and req.user.profile.first_name then req.user.profile.first_name else ''
		]

	async.waterfall [
		(next) ->
			getArticles next
		(docs, next) ->
			data.articles = docs
			next null
		(next) ->
			getFeed req.user, data, next
	], (err) ->
		View.render 'user/main/index', res, data

exports.feed = (req, res) ->
	data = {}
	getFeed req.user, data, () ->
		res.send data

exports.articles = (req, res) ->
	query = _.pick req.query, 'lastId', 'age', 'theme', 'nestedAnchor', 'sort'
	getArticles (err, docs) ->
		res.json docs
	, query

exports.registered = (req, res) ->
	data =
		breadcrumbs: [
			title: 'Ирина'
		]

	View.render 'user/registered/index', res, data
