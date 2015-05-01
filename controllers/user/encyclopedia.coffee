async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Article = require '../../lib/article'
Theme = require '../../lib/theme'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

findAgesThemesArticles = (age, theme, callback) ->
	searchOptions =
		active: true

	async.parallel
		ages: (next) ->
			sortOptions =
				lean: true
				sort:
					value: 1
				limit: 6

			Model 'Age', 'find', searchOptions, 'title value icon desc', sortOptions, next
		themes: (next) ->
			if !age
				return next null, []

			Theme.findThemes age, next
		articles: (next) ->
			docsCount = 24
			query =
				active: true
			options = {}
			if !age && !theme
				options.sort =
					position: -1

				return Model 'Article', 'findPaginated', query, null, options, next, docsCount

			Model 'Age', 'findOne', { value: age }, '_id', (err, doc) ->
				query['age._id'] = doc._id
				query['theme._id'] = theme
				options.nestedAnchor =
					wrap: 'theme'
					field: '_id'
					value: theme
					anchorField: 'position'
				options.sort =
					'theme.position': -1
				Model 'Article', 'findPaginated', query, '-desc.text -image.dataB -image.dataL -image.dataS -image.dataSOCIAL -image.dataXL', options, next, docsCount
	, callback

getSubscription = (user, theme, cb) ->
	if user?._id and theme
		return Model 'Subscription', 'findOne', { client_id: user._id, theme_id: theme }, (err, doc) ->
			cb err, { subscription: doc }

	cb null, { subscription: false }

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'encyclopedia'

	age = req.params.age || null
	theme = req.params.theme || null

	res.locals.params = req.params # req.params is not accessable in middlewares -_-

	async.waterfall [
		(next) ->
			findAgesThemesArticles age, theme, next
		(results, next) ->
			_.extend data, results
			getSubscription req.user, theme, next
		(results) ->
			_.extend data, results
			View.render 'user/encyclopedia/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/encyclopedia/index: #{error}"
		res.send error
