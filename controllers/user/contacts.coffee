async = require 'async'

View = require '../../lib/view'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'
faq = require '../../meta/faq'

exports.index = (req, res) ->
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'contacts'
		faq: faq
	
	View.render 'user/contacts/index', res, data