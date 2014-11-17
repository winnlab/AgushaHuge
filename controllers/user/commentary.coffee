async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport.coffee'
Logger = require '../../lib/logger'
Moneybox = require '../../lib/moneybox'



exports.add = (req, res) ->
	userId = req.user?._id
	_id = req.body?._id
	model = req.body?.model
	content = req.body?.content
	addData = {}
	commentariesLength = 0

	res.locals.params = req.params # req.params is not accessible in middlewares -_-

	if userId and model and _id and content

		async.waterfall [
			(next) ->
				Moneybox.comment userId, next
			(next) ->

				Model model, 'findOne', _id: _id, next

			(doc, next) ->

				if doc

					addData = {
						client: {
							client_id: userId,
							profile: req.user.profile,
							image: req.user.image
						},
						content: content
					}

					commentariesLength = doc.commentaries.push addData

					doc.save next
				else
					next "Error in controllers/user/article/index: No document was found in #{model} model with _id: #{_id}"

			(doc, next) ->
				addData.model = model

				if commentariesLength isnt 0
					addData.commentaryId = doc.commentaries[commentariesLength-1]._id
					addData.commentaryDate = doc.commentaries[commentariesLength-1].date

				View.ajaxResponse res, null, {doc: doc, addData: addData}

		], (err) ->
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/article/index: #{error}"
			res.send error
	else
		Logger.log 'info', "Error in controllers/user/article/index: Not all of the variables were received"
		res.send "Error in controllers/user/article/index: Not all of the variables were received"
