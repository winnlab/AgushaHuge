async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

Tour = require '../../lib/tour'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Tour', 'find', next
		(docs) ->
			View.render 'admin/board/tours/index', res, {tours: docs}
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/tour/index: #{err.message or err}"

exports.get = (req, res) ->
	id = req.params.id
	
	async.waterfall [
		(next) ->
			Model 'Tour', 'findById', next, id
		(doc, next) ->
			if doc
				View.render 'admin/board/tours/edit', res, tour: doc
			else
				next "Произошла неизвестная ошибка!"
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/tour/get: #{err.message or err}"
		View.message false, err.message or err, res

exports.create = (req, res) ->
	View.render 'admin/board/tours/edit', res, tour: {}

exports.save = (req, res) ->
	id = req.body.id
	
	data = req.body
	
	async.waterfall [
		(next) ->
			if id
				Model 'Tour', 'findById', next, id
			else
				next null, null
		(doc, next) ->
			if doc
				for attr of data
					doc[attr] = data[attr]
				
				doc.save next
			else
				Model 'Tour', 'create', next, data
		() ->
			View.message true, 'Экскурсия успешно сохранена!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/tour/save: #{err.message or err}"
		msg = "Произошла ошибка при сохранении: #{err.message or err}"
		View.message false, msg, res

exports.delete = (req, res) ->
	id = req.params.id
	
	async.waterfall [
		(next) ->
			Model 'Tour', 'findById', next, id
		(doc, next) ->
			if doc
				doc.remove() #!!!
				View.message true, 'Экскурсия успешно удалена!', res
			else
				next "Произошла неизвестная ошибка."
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/tour/delete: #{err.message or err}"
		msg = "Произошла ошибка при удалении: #{err.message or err}"
		View.message false, msg, res