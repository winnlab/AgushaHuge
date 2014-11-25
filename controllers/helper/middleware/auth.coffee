
config =
	loginUrl: '/login'
	profileUrl: '/profile'

isNotAuth = () ->
	(req, res, next) ->
		if not req.user
			return res.redirect config.loginUrl

		next()

isAuth = () ->
	(req, res, next) ->
		if req.user
			return res.redirect config.profileUrl


		next()

exports = {
	isNotAuth
	isAuth
}

module.exports = exports
