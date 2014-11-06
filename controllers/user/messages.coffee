async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	breadcrumbs.push
		id: 'profile'
		title: req?.user?.profile?.first_name or ''

	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'messages'

	# async.waterfall [
	# 	(next) ->
	# 		Model 'Consultation', 'find', {
	# 			'author.author_id': req.user._id
	# 			# 'answer.author_id': req.user._id
	# 			'answer':
	# 				req.user._id
	# 		}, next
	# 	(docs, next) ->
	# 		_.extend data, docs
	# 	(next) ->
	#
	# ], (err) ->
	View.render 'user/messages/index', res, data
