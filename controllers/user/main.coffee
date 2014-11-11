async = require 'async'

Model = require '../../lib/mongooseTransport'

View = require '../../lib/view'

exports.index = (req, res) ->
	data =
		breadcrumbs: [
			title: if req.user and req.user.profile and req.user.profile.first_name then req.user.profile.first_name else ''
		]

	async.waterfall [
		(next) ->
			Model 'Article', 'find', {}, null, { sort: { position: -1 } }, next
		(docs, next) ->
			data.articles = docs
			next null
	], (err) ->
		View.render 'user/main/index', res, data

exports.registered = (req, res) ->
	data =
		breadcrumbs: [
			title: 'Ирина'
		]

	View.render 'user/registered/index', res, data
