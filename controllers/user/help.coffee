async = require 'async'

View = require '../../lib/view'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'help'
	
	View.render 'user/help/index', res, data