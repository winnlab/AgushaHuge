async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'


tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

getPaginatedConsultations = (req, cb) ->
	options = _.pick req.query, 'lastId', 'age', 'theme', 'nestedAnchor', 'sort'
	options.sort = created: -1
	options.lean = true
	query = active: true
	docsCount = 24
	anchorId = null

	if options.lastId
		anchorId = options.lastId
		delete options.lastId

	Model 'Consultation', 'findPaginated', query, '_id created', options, (err, docs) ->
		consultation = Model 'Consultation', 'find', { _id: $in: _.pluck docs.documents, '_id' }, '-__v'
		consultation.select watchers: $elemMatch: $in: [req?.user?._id]
		consultation.populate({
			path: 'author.author_id'
			select: 'image created_at'
			model: 'Client'
		}).exec (err, consultations) ->
			docs.documents = consultations
			cb err, docs
	, docsCount, anchorId

getData = (req, cb) ->
	async.parallel
		ages: (proceed) ->
			Model 'Age', 'find', {"active" : true}, null, {sort: {'position': 1}}, proceed
		themes: (proceed) ->
			Model 'Theme', 'find', {"active" : true}, proceed
		articles: (proceed) ->
			getPaginatedConsultations req, proceed
	, cb

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'

	res.locals.params = req.params # req.params is not accessable in middlewares -_-

	async.waterfall [
		(next) ->
			getData req, next
		(results) ->
			_.extend data, results
			View.render 'user/specialist/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/specialist/index: #{error}"
		res.send error

exports.consultations = (req, res) ->
	getPaginatedConsultations req, (err, docs) ->
		res.json docs
