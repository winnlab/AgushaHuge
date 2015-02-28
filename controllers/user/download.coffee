async = require 'async'

View = require '../../lib/view'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'
faq = require '../../meta/faq'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'download'
		faq: faq
	
	View.render 'user/download/index', res, data