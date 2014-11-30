
async = require 'async'
router = require('express').Router()
passport = require 'passport'

Auth = require '../../lib/auth'
View = require '../../lib/view'
Moneybox = require '../../lib/moneybox'

router.use (req, res, next) ->
	if req.user
		return res.redirect '/profile'

	next()

router.get '/', (req, res, next) ->
	View.render 'user/login/index', res

router.get '/vk', passport.authenticate 'vkontakte',
	scope: ['email', 'friends']

router.get '/fb', passport.authenticate 'facebook',
	scope: ['email', 'user_birthday']
 
loginOptions =
	successRedirect: null
	failureRedirect: null

router.post '/', Auth.authenticate('user', loginOptions), (req, res, next) ->
	isAjax = null

	if req.query.ajax
		isAjax = true

	if not isAjax
		return res.redirect '/profile'

	user = req.user?.toObject()

	if not user
		return next new Error 'Пользователь не найден'

	if not user.active
		return next new Error 'Пользователь не активирован'
	
	Moneybox.login user._id, (err, muser) ->
		if muser
			user = muser
		
		delete user.password

	return View.clientSuccess user: user, res

exports = router

module.exports = exports
