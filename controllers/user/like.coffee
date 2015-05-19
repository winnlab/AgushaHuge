async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport.coffee'
Logger = require '../../lib/logger'
Moneybox = require '../../lib/moneybox'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.toggleLike = (req, res) ->
	_id = req.body._id
	userId = req?.user?._id
	model = req.body.model
	toggleResult = null

	res.locals.params = req.params # req.params is not accessible in middlewares -_-

	if _id and userId and model

		async.waterfall [
			(next) ->

				Model model, 'findOne', _id: _id, next

			(doc, next) ->

				if doc

					if doc.likes

						likeIndex = _.findIndex doc.likes, (element) ->
							return element.client.toString() == userId.toString()

						if likeIndex isnt -1
							doc.likes.splice likeIndex, 1
							doc.counter.like -= 1
							toggleResult = 0
						else
							doc.likes.push {client: userId}
							doc.counter.like += 1
							toggleResult = 1

						doc.save next

					else
						doc.likes.push {client: userId}
						doc.counter.like += 1
						toggleResult = 1
						doc.save next
				else
					next "Error in controllers/user/like/toggleLike: No document was found in #{model} model with _id: #{_id}"

			(doc, next) ->
				if toggleResult is 1
					Moneybox.like userId, ->

				View.ajaxResponse res, null, {doc: doc, toggleResult: toggleResult}

		], (err) ->
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/like/toggleLike: #{error}"
			res.send error
	else
		Logger.log 'info', "Error in controllers/user/like/toggleLike: Not all of the variables were received"
		res.send "Error in controllers/user/like/toggleLike: Not all of the variables were received"



exports.socialLike = (req, res) ->
	return res.send 400 unless req.body?.network
	return res.send 403 unless req.user

	Moneybox.socialLike req?.user?._id, req.body.network, () ->
		res.send req.body.network
