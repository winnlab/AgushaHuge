async = require 'async'

View = require '../../lib/view'

indexDataFunc = (req, res, callback) ->
	callback null, {}

exports.index = (req, res) ->
	# View.render req, res, 'user/main', indexDataFunc
	View.renderJade req, res, 'user/main'