async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'



exports.index = (req, res) ->
	userImage = getUserImage req.user
	
	clonedBreadcrumbs = _.clone breadcrumbs
	
	clonedBreadcrumbs.push
		id: 'profile'
		title: req?.user?.profile?.first_name or ''

	data =
		breadcrumbs: tree.findWithParents clonedBreadcrumbs, 'messages'
		userImage: userImage

	View.render 'user/messages/index', res, data


getUserImage = (user) ->
	return "/img/user/helpers/stub/small.png" unless user
	return "/img/user/helpers/stub/small.png" unless user.image?.small

	"/img/uploads/#{user.image.small}"


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



exports.markConversationAsRead = (req, res) ->
	data = req.body

	return View.ajaxResponse res, 403, 'Unauthorized user' unless req.user
	return View.ajaxResponse res, 400, 'Empty conversation ID' unless data?.conversationId

	async.waterfall [
		(next) ->
			Model 'Conversation', 'findOne', {'_id': data.conversationId}, next
		(doc, next) ->
			return View.ajaxResponse res, 404, 'Conversation not found' unless doc

			readChangeFlag = false

			_.each doc.interlocutors, (interlocutor) ->
				if req.user._id.toString() is interlocutor.client.toString() and interlocutor.read is false
					interlocutor.read = true
					readChangeFlag = true

			if readChangeFlag
				doc.save next
			else
				View.ajaxResponse res, null, doc

		(doc, next) ->
			View.ajaxResponse res, null, doc

	], (err) ->
		View.ajaxResponse res, err, null