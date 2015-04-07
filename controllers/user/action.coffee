async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Product = require '../../lib/product'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'action'
	
	View.render 'user/action/index', res, data