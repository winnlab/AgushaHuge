async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
mongoose = require 'mongoose'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Theme', 'find', next, {}, '-__v'
		(docs) ->
			View.render 'admin/board/theme/index', res, themes: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/theme/index: %s #{err.message or err}"

exports.save = (req, res) ->
	Model('Theme', 'remove', null, {}).exec()

	data = req.body.items
	_ids = {}

	iterator = (item, cb) ->
		async.waterfall [
			(next) ->
				Model 'Theme', 'findOne', next, _id: item._id
			(doc, next) ->
				unless doc
					doc = new mongoose.models.Theme

				doc.name = item.name
				doc.active = if typeof item.active isnt 'undefined' then item.active else true

				if item.parent
					doc.pid = item.parent
				else if item.parenttId
					pid = _ids[item.parenttId]
					if pid
						doc.pid = pid
					else
						throw new Error "No parent id exists for parent: #{item.parenttId}"

				doc.save next
			(doc) ->
				_ids[item.tId] = doc._id
				cb()

		], cb

	callback = (err) ->
		if err
			msg = "Ошибка при сохранении: #{err.message or err}"
		else
			msg = 'Данные успешно сохранены!'

		res.send msg

	async.eachSeries data, iterator, callback