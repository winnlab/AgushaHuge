async = require 'async'
fs = require 'fs'
moment = require 'moment'
mongoose = require 'mongoose'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
array = require '../../utils/array'

entityModelType = 1

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'quiz', 'findQuizes', next
		(docs, next) ->
			Model 'quiz', 'populate', next, docs, 'theme years author'
		(docs) ->
			for item in docs
				item.authorName = item.author?.login or '{редакция}'
			View.render 'admin/board/quizes/index', res, quizes: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/quizes/index: %s #{err.message or err}"

preloadData = (quiz, cb) ->
	if typeof quiz is 'function'
		cb = quiz
		quiz = {}

	async.parallel
		years: (next) ->
			Model 'Years', 'find', next, active: true, '-__v'
		theme: (next) ->
			async.waterfall [
				(next2) ->
					Model 'Theme', 'find', next2, active: true, '-__v'
				(docs) ->
					Model 'Theme', 'populate', next, docs, 'tags'
			], next
		client: (next) ->
			Model 'Client', 'find', next, active: true, '_id login status'
	, (err, results)->
		cb err if err

		results.quiz = quiz

		results.years = array.makeTreeForSelect results.years
		results.theme = array.makeTreeForSelect results.theme
		results.cTags = {}
		for item in quiz.tags
			results.cTags[item] = true

		themeAdjusted = {}
		for t in results.theme
			themeAdjusted[t._id] = t.tags

		results.themeAdjusted = JSON.stringify themeAdjusted
		results.themeAdjustedObject = themeAdjusted

		if results.quiz.author
			results.quiz.authorName = results.quiz.author.login
		else
			results.quiz.authorName = '{редакция}'

		cb null, results

exports.get = (req, res) ->
	id = req.params.id
	async.waterfall [
		(next) ->
			Model 'quiz', 'findOne', next, _id: id
		preloadData
		(results) ->
			View.render 'admin/board/quizes/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/quizes/get: %s #{err.message or err}"
		View.message false, err.message or err, res

exports.create = (req, res) ->
	async.waterfall [
		preloadData
		(results) ->
			View.render 'admin/board/quizes/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/quizes/create: %s #{err.message or err}"

exports.save = (req, res) ->
	_id = req.body.id

	data = req.body
	data.background = req.files.background?.name
	data.desc_image = []
	data.type = entityModelType
	data.updated = moment()
	if data.author is '0'
		data.author = null

	if req.files?.desc_image
		if req.files.desc_image.name
			data.desc_image.push req.files.desc_image.name
		else
			for img in req.files.desc_image
				data.desc_image.push img.name

	async.waterfall [
		(next) ->
			if _id
				out_doc = false
				async.waterfall [
					(next2) ->
						Model 'quiz', 'findOne', next2, {_id}
					(doc) ->
						if data.quizname and data.quiz_id
							quizData = []
							for item, i in data.quiz_id
								quizData.push {
									_id: item
									name: data.quizname[i]
								}

							iterator = (item, cb) ->
								if item._id == '-1'
									answ = new mongoose.models.QuizAnswer
									answ.name = item.name
									answ.save cb
								else
									Model 'quizAnswer', 'findOne', (err, answ) ->
										answ.name = item.name
										answ.save cb
									, _id: item._id

							async.mapSeries quizData, iterator, (err, results) ->
								if err
									return Logger.log 'error', 'Error saving quiz variant: ', err

								_ids = []
								if results
									for item in results
										_ids.push item._id
									delete data.quizname
									delete data.quiz_id
									data.quiz = _ids

								next null, doc
						else
							next null, doc, []
					(doc, _ids) ->
						for own prop, val of data

							unless prop is 'id' or val is undefined
								if prop is 'desc_image'
									doc[prop] = doc[prop].concat val
								else
									doc[prop] = val

						doc.save next
				], (err) ->
					next err
			else
				Model 'quiz', 'create', next, data
		(doc, next) ->
			if not doc
				return next "Произошла неизвестная ошибка."

			View.message true, 'Опрос успешно сохранен!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/quizes/save: #{err.message or err}", err
		msg = "Произошла ошибка при сохранении: #{err.message or err}"
		View.message false, msg, res

exports.delete = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'quiz', 'findOneAndRemove', next, {_id}
		() ->
			View.message true, 'Опрос успешно удален!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/quizes/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		View.message false, msg, res

exports.deleteImage = (req, res) ->
	_id = req.params.id
	img = req.params.img
	async.waterfall [
		(next) ->
			Model 'quiz', 'findOne', next, {_id}
		(doc, next) ->
			fs.unlink "./public/img/#{img}", (err) ->
				next err, doc
		(doc, next) ->
			images = doc.desc_image
			idx = images.indexOf img
			doc.images = images.splice idx, 1

			doc.save next
		() ->
			#View.message true, 'Изображение удалено!', res
			res.send true
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/quizes/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		#View.message false, msg, res
		res.send msg