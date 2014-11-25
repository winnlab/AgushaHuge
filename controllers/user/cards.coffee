async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

exports.index = (req, res) ->
	View.render 'user/cards/index', res