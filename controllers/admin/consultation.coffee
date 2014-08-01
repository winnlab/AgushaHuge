async = require 'async'
mongoose = require 'mongoose'

Model = require '../../lib/model'
View = require '../../lib/view'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Consultation', 'find', next, {
				closed: false
				active: true
			}
		(docs, next) ->
			Model 'Contribution', 'populate', next, docs, 'theme years user author'
		(docs) ->
			View.render 'admin/board/consultation/index', res, consultations: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/consultation/index:", err

exports.view = (req, res) ->
	_id = req.params.id
	consultation = {}
	async.waterfall [
		(next) ->
			query = Model 'Consultation', 'findOne', null, _id: _id
			
			query
				.populate('author answer answer.author tags theme years user')
				.exec next
		(doc, next) ->
			consultation = doc
			Model 'Answer', 'populate', next, doc.answer, 'author'
		(docs) ->
			View.render 'admin/board/consultation/view', res, 
				consultation: consultation
				messages: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/consultation/view:", err

exports.update = (req, res) ->
	_id = req.body._id
	text = req.body.answer
	consultation = null

	async.waterfall [
		(next) ->
			Model 'Consultation', 'findOne', next, _id: _id
		(doc, next) ->
			unless doc
				return next 'Ошибка при сохранении - нет консультации с таким _id.'

			consultation = doc

			answer = new mongoose.models.Answer
			answer.text = text
			answer.specialist = req.user._id
			answer.save next
		(answer, affected, next) ->
			consultation.answer.push answer._id
			consultation.closed = true
			consultation.save next
		(doc) ->
			View.message true, 'Ответ успешно добавлен!', res

	], (err) ->
		Logger.log 'info', 'Error in controllers/admin/consultation/update', err

		View.message false, err, res

exports.remove = (req, res) ->
	_id = req.params.id

	async.waterfall [
		(next) ->
			Model 'Consultation', 'findOne', next, _id: _id
		(doc, next) ->
			doc.active = false
			doc.save next
		(results, affected, next) ->
			View.message true, 'Консультация удалена!', res
	], (err) ->
		Logger.log 'info', 'Error in controllers/admin/consultation/remove', err

		View.message false, err, res