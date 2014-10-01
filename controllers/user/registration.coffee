async = require 'async'

View = require '../../lib/view'

exports.index = (req, res) ->
	View.render 'user/registration/index', res