async = require 'async'
moment = require 'moment'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'User', 'findOne', next, username: req.user.username
		(doc) ->
			View.render 'admin/board/profile/index', res, user: doc

	], (err) ->
		Logger.log 'info', "Error in controllers/admin/profile/index: %s #{err.message or err}"
		View.message false, err.message or err, res

exports.save = (req, res) ->
	data = req.body
	delete data._wysihtml5_mode if data._wysihtml5_mode

	data.photo = req.files?.photo?.name or undefined
	async.waterfall [
		(next) ->
			async.waterfall [
				(next2) ->
					Model 'User', 'findOne', next2, username: req.user.username
				(doc) ->
					for own prop, val of data
						unless val is undefined
							doc[prop] = val

					doc.save next
			], next
		(doc, next) ->
			if doc
				View.message true, 'Профиль успешно сохранен!', res
			else
				next "Произошла неизвестная ошибка."
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/category/save: #{err.message or err}"
		msg = "Произошла ошибка при сохранении: #{err.message or err}"
		View.message false, msg, res