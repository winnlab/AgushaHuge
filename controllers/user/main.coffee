_ = require 'lodash'
underscore = require 'underscore'
async = require 'async'
moment = require 'moment'

Model = require '../../lib/mongooseTransport'

View = require '../../lib/view'

string = require '../../utils/string'

getSubscriptions = (userId, cb) ->
	async.waterfall [
		(next) ->
			Model 'Subscription', 'find', { client_id: userId }, next
		(docs, next) ->
			Model 'Article', 'find', { 'theme._id': { $in: _.pluck(docs, 'theme_id') } }, next
	], (err, docs) ->
		cb err, (if docs.length then docs else [])

getConsultations = (userId, cb) ->
	async.waterfall [
		(next) ->
			Model 'Watcher', 'find', { client_id: userId }, next
		(docs, next) ->
			Model 'Consultation', 'find', {
				$or: [
					_id:
						$in: _.pluck(docs, 'consultation_id')
				,
					'author.author_id': userId
				]
			}, next
	], (err, docs) ->
		cb err, (if docs.length then docs else [])

getFeed = (user, data, cb) ->
	unless user and user._id
		_.extend data, { themeSubs: [], consultations: [] }
		return cb null

	async.parallel {
		themeSubs: (proceed) ->
			getSubscriptions user._id, proceed
		consultations: (proceed) ->
			getConsultations user._id, proceed
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
	if req.query?.referer
		res.cookie('referer', req.query.referer, {maxAge: 2592000000})
	
	currentDate = moment()
	endDate = moment '20.05.2015', 'DD.MM.YYYY'
	diff = endDate.diff currentDate
	
	duration = moment.duration diff
	
	data =
		breadcrumbs: [
			title: if req.user and req.user.profile and req.user.profile.first_name then req.user.profile.first_name else ''
		]
		duration:
			days: underscore.chars string.leftPad duration._data.days, 2
			hours: underscore.chars string.leftPad duration._data.hours, 2
			minutes: underscore.chars string.leftPad duration._data.minutes, 2
			diff: diff
	
	async.waterfall [
		(next) ->
			getArticles next
		(docs, next) ->
			data.articles = docs
			
			getFeed req.user, data, next
	], (err) ->
		if err
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/main/index: #{error}"
			return res.send error
		
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