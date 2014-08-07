async = require 'async'
fs = require 'fs'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Image = require '../../lib/image'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Article', 'findArticles', next
		(docs) ->
			View.render 'admin/board/articles/index', res, articles: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/articles/index: %s #{err.message or err}"

exports.get = (req, res) ->
	id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Article', 'findOne', next, _id: id
		(doc, next) ->
			if doc
				View.render 'admin/board/articles/edit', res, article: doc
			else
				next "Произошла неизвестная ошибка!"
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/articles/get: %s #{err.message or err}"
		View.message false, err.message or err, res

exports.create = (req, res) ->
	View.render 'admin/board/articles/edit', res,
		article: {}

exports.save = (req, res) ->
	_id = req.body.id

	data = req.body
	data.desc_image = []
	if req.files?.desc_image
		if req.files.desc_image.name
			data.desc_image.push req.files.desc_image.name
		else
			for img in req.files.desc_image
				data.desc_image.push img.name

	async.waterfall [
		(next) ->
			if _id
				async.waterfall [
					(next2) ->
						Model 'Article', 'findOne', next2, {_id}
					(doc) ->
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
				Model 'Article', 'create', next, data
		(doc, next) ->
			if not doc
				return next "Произошла неизвестная ошибка."

			View.message true, 'Статья успешно сохранена!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/articles/save: %s #{err.message or err}"
		msg = "Произошла ошибка при сохранении: #{err.message or err}"
		View.message false, msg, res

exports.delete = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Article', 'findOneAndRemove', next, {_id}
		() ->
			View.message true, 'Статья успешно удалена!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/articles/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		View.message false, msg, res

exports.deleteImage = (req, res) ->
	_id = req.params.id
	img = req.params.img
	async.waterfall [
		(next) ->
			Model 'Article', 'findOne', next, {_id}
		(doc, next) ->
			Image.doRemoveImage img, (err) ->
				next err, doc
		(doc, next) ->
			images = doc.desc_image
			idx = images.indexOf img
			doc.images = images.splice idx, 1

			doc.save next
		() ->
			res.send true
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/articles/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"

		res.send msg