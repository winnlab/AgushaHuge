async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	breadcrumbs.push
		id: 'profile'
		title: if req.user and req.user.profile and req.user.profile.first_name then req.user.profile.first_name else ''
	
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'messages'
	
	View.render 'user/messages/index', res, data