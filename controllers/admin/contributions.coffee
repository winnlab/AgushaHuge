async = require 'async'
fs = require 'fs'
moment = require 'moment'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
MyModel = require '../../lib/contribution'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Contribution', 'findArticles', next
		(docs, next) ->
			Model 'Contribution', 'populate', next, docs, 'theme years author'
		MyModel.aggregateRelations
		(results) ->
			View.render 'admin/board/contributions/index', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/index: %s #{err.message or err}"

exports.get = (req, res) ->
	id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Contribution', 'findOne', next, _id: id
		MyModel.preloadData
		(results) ->
			View.render 'admin/board/contributions/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/get: %s #{err.message or err}"
		View.message false, err.message or err, res

exports.create = (req, res) ->
	async.waterfall [
		MyModel.preloadData
		(results) ->
			View.render 'admin/board/contributions/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/create: %s #{err.message or err}"

exports.save = (req, res) ->
	_id = req.body.id

	data = req.body
	data.background = req.files.background?.name
	data.desc_image = []
	data.type = 0
	data.updated = moment()

	data.active = if data.active then true else false
	data.recommended = if data.recommended then true else false
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
				async.waterfall [
					(next2) ->
						Model 'Contribution', 'findOne', next2, {_id}
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
				Model 'Contribution', 'create', next, data
		(doc, next) ->
			if not doc
				return next "Произошла неизвестная ошибка."

			View.message true, 'Статья успешно сохранена!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/save: #{err.message or err}", err
		msg = "Произошла ошибка при сохранении: #{err.message or err}"
		View.message false, msg, res

exports.delete = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Contribution', 'findOneAndRemove', next, {_id}
		() ->
			View.message true, 'Статья успешно удалена!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		View.message false, msg, res

exports.deleteImage = (req, res) ->
	_id = req.params.id
	img = req.params.img
	async.waterfall [
		(next) ->
			Model 'Contribution', 'findOne', next, {_id}
		(doc, next) ->
			fs.unlink "./public/img/#{img}", (err) ->
				next err, doc
		(doc, next) ->
			images = doc.desc_image
			idx = images.indexOf img
			doc.images = images.splice idx, 1

			doc.save next
		() ->
			res.send true
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"

		res.send msg