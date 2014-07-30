async = require 'async'

Model = require '../../lib/model'
View = require '../../lib/view'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Consultation', 'find', next, closed: false
		(docs, next) ->
			Model 'Contribution', 'populate', next, docs, 'theme years user answer'
		(docs) ->
			View.render 'admin/board/consultation/index', res, consultations: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/consultation/index:", err