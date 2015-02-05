
async = require 'async'
router = require('express').Router()
passport = require 'passport'

Auth = require '../../lib/auth'
View = require '../../lib/view'
Moneybox = require '../../lib/moneybox'
Crud = require '../../lib/crud'
Email = require '../../lib/mail'
config = require '../../config.json'
md5 = require 'MD5'

User = new Crud
	modelName: 'Client'

# router.use (req, res, next) ->
# 	if req.user
# 		return res.redirect '/profile'

# 	next()


uniqueId = (length) ->
	i = 0
	text = ""
	possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

	while i < length
		text += possible.charAt(Math.floor(Math.random() * possible.length))
		i++

	return text

restoreEmail = (user, password, callback) ->
	emailMeta =
		toName: "#{user.profile.first_name}"
		to: user.email
		subject: "Восстановление пароля"
		user: user
		newPassword: password

	Email.send 'repassword', emailMeta, callback

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
		return next 'Пользователь не найден'
	
	Moneybox.login user._id, (err, muser) ->
		if muser
			user = muser
		
		delete user.password

	return View.clientSuccess user: user, res

router.get '/restore', (req, res, next) ->


router.post '/restore', (req, res, next) ->
	email = req.body.email.toLocaleLowerCase()

	if not email
		return next 'Пользователь с такой почтой не найден'

	callback = (err, user) ->
		if err
			console.log err
			return next new Error "Что то пошло не так. Обратитесь к администратору"

		newPassword = uniqueId 7

		if not user
			console.log 'user not fount'
			return next new Error "Пользвоатель не найден"

		user.password = newPassword

		user.save (err) ->
			if err
				console.log err
				return next new Error "Что то пошло не так. Обратитесь к администратору"

			restoreEmail user, newPassword, (err) ->
				if err
					console.log 'failed send email'

				return next new Error "Что то пошло не так. Обратитесь к администратору" if err

				console.log 'email sended'

				return View.clientSuccess
					user: user
					message: "Данные отправлены Вам на почту"
				, res

	User.DataEngine 'findOne', callback, email: email

router.post '/linkVk', (req, res) ->
	data = req.body
	vkData = data.response.session

	sign = md5 "expire=#{vkData.expire}mid=#{vkData.mid}secret=#{vkData.secret}sid=#{vkData.sid}#{config.vk.CLIENT_SECRET}"

	if sign is vkData.sig
		if req.user
			async.waterfall [
				(next) ->
					User.DataEngine 'findOne', next, _id: req.user._id
				(doc, next) ->
					if doc
						doc.social.vk = {
							id: vkData.user.id
						}

						doc.save next
				(next) ->
					res.send vkData.user.id
			], (err) ->
				res.send err

exports = router

module.exports = exports