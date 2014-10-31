View = require '../../lib/view'

exports.get = (req, res) ->
	if req.user
	    data =
	        _id: req.user?._id or false
	        name: "#{req.user?.firstName} #{req.user?.lastName}"

    View.ajaxResponse res, null, data