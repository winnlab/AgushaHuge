url = require 'url'

_ = require 'underscore'
passport = require 'passport'
async = require 'async'
roles = require 'roles'

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

exports.isAdmin = (req, res, next) ->
	parseUrl = req._parsedUrl.pathname.split '/'
	section = if parseUrl[2] then parseUrl[2] else 'dashboard'
	
	if section == 'login'
		return next()
	
	if not req.user
		return res.send 'You are not logged in'
	
	async.waterfall [
		(next2) ->
			role = req.user.getRole()
			
			profile = roles.getProfile role
			
			if not profile
				return res.send 'Your account has unexpected permissions'
			
			if not profile.hasRoles 'agusha.' + section
				return res.send 'Your profile does not have required permissions'
			
			return next()
	], (err) ->
		return next err

exports.authenticate = (strategy, lparams = {}) ->
	stratParams = _.extend params[strategy], lparams

	passport.authenticate strategy, stratParams
