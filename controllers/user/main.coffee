async = require 'async'

View = require '../../lib/view'

exports.index = (req, res) ->
	View.renderJade req, res, 'user/main'