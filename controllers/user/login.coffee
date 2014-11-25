
async = require 'async'
router = require('express').Router()
passport = require 'passport'

Auth = require '../../lib/auth'
View = require '../../lib/view'
Moneybox = require '../../lib/moneybox'

router.get '/', (req, res, next) ->
	View.render 'user/login/index', res

router.get '/vk', passport.authenticate 'vkontakte',
	scope: ['email', 'friends']

router.get '/fb', passport.authenticate 'facebook',
	scope: ['email', 'user_birthday']

# router.get '/ok', 

router.post '/', Auth.authenticate('user', {successRedirect: null, failureRedirect: null}), (req, res, next) ->
	isAjax = res.locals?.is_ajax_request

	if not isAjax
		return res.redirect '/profile'

	user = req.user?.toObject()

	if not user
		return View.clientFail new Error 'User not exist', res
	
	Moneybox.login user._id, (err, muser) ->
		if muser
			user = muser
		
		delete user.password

		return View.clientSuccess user: user, res


exports = router

module.exports = exports
