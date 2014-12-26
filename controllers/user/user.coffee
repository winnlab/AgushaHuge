
router = require('express').Router()
View = require('../../lib/view')

router.get '/', (req, res) ->
	user = null
	res.locals.is_ajax_request = true

	if req.user and req.user._id
		user = req.user.toObject()
		if user.password
			user.standardRegistration = true
		delete user.password

	res.locals.user = user

	View.render null, res

exports = router

module.exports = router
