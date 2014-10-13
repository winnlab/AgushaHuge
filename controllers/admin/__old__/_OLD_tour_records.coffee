async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

Tour_record = require '../../lib/tour_record'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Tour_record', 'find', next
		(docs, next) ->
			Model 'Tour_record', 'populate', next, docs, 'tour'
		(docs) ->
			View.render 'admin/board/tour_records/index', res, {tour_records: docs}
	], (err) ->
		Logger.log 'info', "Error in lib/tour_record/index: #{err.message or err}"

exports.item = (req, res) ->
	id = req.params.id
	
	async.waterfall [
		(next) ->
			Model 'Tour_record', 'findById', next, id
		(doc, next) ->
			Model 'Tour_record', 'populate', next, doc, 'tour'
		(doc) ->
			View.render 'admin/board/tour_records/item', res, {tour_record: doc}
			
			doc.is_read = true
			doc.save()
	], (err) ->
		Logger.log 'info', "Error in lib/tour_record/item: #{err.message or err}"