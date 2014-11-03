
async = require 'async'
router = require('express').Router()
passport = require 'passport'

Auth = require '../../lib/auth'
View = require '../../lib/view'

router.get '/', (req, res, next) ->
	View.render 'user/login/index', res

router.post '/', Auth.authenticate('user', {successRedirect: null, failureRedirect: null}), (req, res, next) ->
	isAjax = res.locals?.is_ajax_request

	if not isAjax
		return res.redirect '/profile';

	user = req.user?.toObject()

	if user
		delete user.password
		return View.clientSuccess user: user, res

	return View.clientFail new Error 'User not exist', res

exports = router

module.exports = exports
