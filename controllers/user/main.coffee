async = require 'async'

View = require '../../lib/view'

exports.index = (req, res) ->
	View.render 'user/main/index', res

exports.registered = (req, res) ->
	data = 
		breadcrumbs: [
			title: 'Ирина'
		]
	
	View.render 'user/registered/index', res, data