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

	View.render 'user/messages/index', res, data



exports.getConversations = (req, res) ->

	if req.user
		async.waterfall [
			(next) ->
				conversations = Model 'Conversation', 'find', {'interlocutors.client': req.user._id}, null
				conversations.populate('interlocutors.client').exec next
			(docs, next) ->
				View.ajaxResponse res, null, docs

		], (err) ->
			View.ajaxResponse res, err, null
	else
		View.ajaxResponse res, 403, 'Unauthorized user'