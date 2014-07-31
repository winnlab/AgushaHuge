async = require 'async'

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
			Model 'Contribution', 'populate', next, docs, 'theme years user'
		(docs) ->
			View.render 'admin/board/consultation/index', res, consultations: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/consultation/index:", err

exports.view = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Consultation', 'findOne', next, _id: _id
		(doc, next) ->
			Model 'Contribution', 'populate', next, doc, 'tags theme years user answers'
		(doc) ->
			View.render 'admin/board/consultation/view', res, consultation: doc
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/consultation/view:", err