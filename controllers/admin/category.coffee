async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
mongoose = require 'mongoose'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Category', 'find', next
		(docs) ->
			View.render 'admin/board/category/index', res, {categories: docs}
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/category/index: %s #{err.message or err}"

exports.get = (req, res) ->
	id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Category', 'findOne', next, _id: id
		(doc, next) ->
			if doc
				View.render 'admin/board/category/edit', res, category: doc
			else
				next "Произошла неизвестная ошибка!"
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/category/get: %s #{err.message or err}"
		View.message false, err.message or err, res

exports.create = (req, res) ->
	View.render 'admin/board/category/edit', res,
		category: {}

exports.save = (req, res) ->
	_id = req.body.id

	data = req.body
	delete data._wysihtml5_mode if data._wysihtml5_mode

	async.waterfall [
		(next) ->
			if _id
				async.waterfall [
					(next2) ->
						Model 'Category', 'findOne', next2, {_id}
					(doc) ->
						for own prop, val of data
							unless prop is 'id' or val is undefined
								doc[prop] = val

						doc.active = data.active or false

						doc.save next
				], (err) ->
					next err
			else
				Model 'Category', 'create', next, data
		(doc, next) ->
			if doc
				View.message true, 'Категория успешно сохранена!', res
			else
				next "Произошла неизвестная ошибка."
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/category/save: %s #{err.message or err}"
		msg = "Произошла ошибка при сохранении: #{err.message or err}"
		View.message false, msg, res

exports.delete = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Category', 'findOne', next, _id: _id
		(doc, next) ->
			if doc
				doc.remove next
			else
				next null
		(next) ->
			View.message true, 'Категория успешно удалена!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/category/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		View.message false, msg, res

exports.position = (req, res) ->
	c_id = req.params.id
	async.parallel 
		category: (next) ->
			Model 'Category', 'findOne', next, _id: c_id
		positions: (next) ->
			async.waterfall [
				(next2) ->
					Model 'ProductPosition', 'find', next2, c_id: c_id, '_id c_id p_id position', sort: {position: 1}
				(docs, next2) ->
					opts = 'p_id'
					Model 'ProductPosition', 'populate', next2, docs, opts
				(docs) ->
					next null, docs
			], (err) ->
				next err
	, (err, results) ->
		View.render 'admin/board/category/position', res, results

exports.savePosition = (req, res) ->
	cId = req.body.c_id
	pIds = req.body.positions.split ','
	productPositions = []
	for val, pos in pIds
		productPositions.push {
			c_id: cId
			p_id: val
			position: pos
		}

	iterator = (item, cb) ->
		where = 
			c_id: item.c_id
			p_id: item.p_id
		what =
			position: item.position
		Model 'ProductPosition', 'update', cb, where, what

	callback = (err) ->

		if err
			success = false
			msg = "Произошла ошибка при сохранении: #{err.message or err}"
		else
			success = true
			msg = "Позиции успешно сохранены!"

		View.message success, msg, res

	async.each productPositions, iterator, callback