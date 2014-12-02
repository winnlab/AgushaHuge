async = require 'async'

View = require '../../lib/view'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'
faq = require '../../meta/faq'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'help'
		tab: req.params.tab
	
	if req.params.tab == 'faq'
		data.faq = faq
	
	View.render 'user/help/index', res, data