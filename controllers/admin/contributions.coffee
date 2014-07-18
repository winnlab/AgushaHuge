async = require 'async'
fs = require 'fs'
moment = require 'moment'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
array = require '../../utils/array'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Contribution', 'find', next
		(docs, next) ->
			Model 'Contribution', 'populate', next, docs, 'theme years author'
		(docs) ->
			for item in docs
				item.authorName = item.author?.login or '{редакция}'
			View.render 'admin/board/contributions/index', res, contributions: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/index: %s #{err.message or err}"

preloadData = (contribution, cb) ->
	if typeof contribution is 'function'
		cb = contribution
		contribution = {}

	async.parallel
		years: (next) ->
			Model 'Years', 'find', next, active: true
		theme: (next) ->
			Model 'Theme', 'find', next, active: true
		client: (next) ->
			Model 'Client', 'find', next, active: true, '_id login status'
	, (err, results)->
		cb err if err

		results.contribution = contribution

		results.years = array.makeTreeForSelect results.years
		results.theme = array.makeTreeForSelect results.theme
		if results.contribution.author
			results.contribution.authorName = results.contribution.author.login
		else
			results.contribution.authorName = '{редакция}'

		cb null, results

exports.get = (req, res) ->
	id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Contribution', 'findOne', next, _id: id
		preloadData
		(results) ->
			View.render 'admin/board/contributions/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/get: %s #{err.message or err}"
		View.message false, err.message or err, res

exports.create = (req, res) ->
	async.waterfall [
		preloadData
		(results) ->
			View.render 'admin/board/contributions/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/create: %s #{err.message or err}"

exports.save = (req, res) ->
	_id = req.body.id

	data = req.body
	data.background = req.files.background?.name
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
						Model 'Contribution', 'findOne', next2, {_id}
					(doc) ->
						for own prop, val of data
							unless prop is 'id' or val is undefined
								if prop is 'author' and val is '0'
									doc[prop] = null
								else if prop is 'desc_image'
									doc[prop] = doc[prop].concat val
								else
									doc[prop] = val

						doc.updated = moment()
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
			#View.message true, 'Изображение удалено!', res
			res.send true
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/contributions/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		#View.message false, msg, res
		res.send msg