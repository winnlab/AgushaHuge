async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport.coffee'
Logger = require '../../lib/logger'



exports.toggleRating = (req, res) ->
	_id = req.body._id
	userId = req.user?._id
	commentaryId = req.body.commentary_id
	ratingValue = req.body.ratingValue
	model = req.body.model

	res.locals.params = req.params # req.params is not accessible in middlewares -_-

	if _id and model and commentaryId and ratingValue

		ratingValue = parseInt(ratingValue)

		if userId
			async.waterfall [
				(next) ->

					Model model, 'findOne', _id: _id, next

				(doc, next) ->

					if doc

						if doc.commentaries

							commentaryIndex = _.findIndex doc.commentaries, (commentary) ->
								return commentary._id.toString() == commentaryId.toString()

							if commentaryIndex isnt -1
								if doc.commentaries[commentaryIndex].rating
									ratingIndex = _.findIndex doc.commentaries[commentaryIndex].rating, (ratingItem) ->
										return ratingItem.client.toString() == userId.toString()

									if ratingIndex isnt -1
										if doc.commentaries[commentaryIndex].rating[commentaryIndex].value isnt ratingValue
											if ratingValue is 1
												doc.commentaries[commentaryIndex].scoreInc += 1
												doc.commentaries[commentaryIndex].scoreDec -= 1
											else if ratingValue is -1
												doc.commentaries[commentaryIndex].scoreInc -= 1
												doc.commentaries[commentaryIndex].scoreDec += 1

										doc.commentaries[commentaryIndex].rating[commentaryIndex].value = ratingValue
									else
										if ratingValue is 1
											doc.commentaries[commentaryIndex].scoreInc += 1
										else if ratingValue is -1
											doc.commentaries[commentaryIndex].scoreDec += 1

										doc.commentaries[commentaryIndex].rating.push {
											client: userId,
											value: ratingValue
										}
								else
									if ratingValue is 1
										doc.commentaries[commentaryIndex].scoreInc = 1
									else if ratingValue is -1
										doc.commentaries[commentaryIndex].scoreDec = 1

									doc.commentaries[commentaryIndex].rating.push {
										client: userId,
										value: ratingValue
									}

							else
								next "Error in controllers/user/article/index: No commentary was found in #{model} model with commentary _id: #{commentaryId}"

							doc.save next

						else
							next "Error in controllers/user/article/index: No commentaries were found in #{model} model with _id: #{_id}"
					else
						next "Error in controllers/user/article/index: No document was found in #{model} model with _id: #{_id}"

				(doc, next) ->

					View.ajaxResponse res, null, {doc: doc}

			], (err) ->
				error = err.message or err
				Logger.log 'info', "Error in controllers/user/article/index: #{error}"
				res.send error

		else
			res.send "Error in controllers/user/article/index: Unauthorized user"
	else
		Logger.log 'info', "Error in controllers/user/article/index: Not all of the variables were received"
		res.send "Error in controllers/user/article/index: Not all of the variables were received"