
url = require 'url'

_ = require 'underscore'
passport = require 'passport'

config = require '../config.json'

params =
	admin:
		failureRedirect: '/admin/login'
		successRedirect: "/admin/#{config.adminRootPath}"
		session: true
	user:
		failureRedirect: '/login'
		successRedirect: '/profile'
		session: true

exports.isAuth = (req, res, next)->
	path = url.parse req.path

	if path.path == '/login'
		return next()

	if not req.user or not req.isAuthenticated()
		return res.redirect '/admin/login'

	next()

exports.authenticate = (strategy, lparams = {}) ->
	stratParams = _.extend params[strategy], lparams

	passport.authenticate strategy, stratParams
