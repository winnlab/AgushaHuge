_ = require 'underscore'
async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'

exports.years = (req, res) ->
    Model 'Years', 'find', {}, '-__v', async.apply View.ajaxResponse, res

exports.themes = (req, res) ->
	years_id = req.params.years_id
	
	unless years_id
		return View.ajaxResponse res, null, []

	Model 'Theme', 'find', {years_id}, '-__v', async.apply View.ajaxResponse, res