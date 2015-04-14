async = require 'async'
moment = require 'moment'
passport = require 'passport'
MD5 = require 'MD5'
_ = require 'lodash'

router = require('express').Router()

Crud = require '../../lib/crud'
View = require '../../lib/view'
Logger = require '../../lib/logger'
Model = require '../../lib/model'
Email = require '../../lib/mail'
Auth = require '../../lib/auth'
Moneybox = require '../../lib/moneybox'

crud = new Crud
	modelName: 'Client'

activateEmail = (user, callback) ->
	emailMeta =
		toName: "#{user.profile.first_name}"
		to: user.email
		subject: "Активация аккаунта на agusha.com.ua"
		user: user
	
	Email.send 'letter_regist_3', emailMeta, callback

# router.use (req, res, next) ->
# 	if req.user
# 		return res.redirect '/profile'

# 	next()

router.get '/', (req, res, next) ->
	if req.user
		return res.redirect '/profile'

	View.render 'user/registration/index', res

router.get '/fb', passport.authenticate 'facebook',
	scope: ['email', 'user_birthday']

router.get '/vk', passport.authenticate 'vkontakte',
	successRedirect: '/profile'
	failureRedirect: '/login'

router.get '/ok', passport.authenticate 'odnoklassniki',
	scope: ['email', 'friends']

router.get '/fb/callback', passport.authenticate 'facebook',
	successRedirect: '/profile'
	failureRedirect: '/login'

router.get '/vk/callback', passport.authenticate 'vkontakte',
	successRedirect: '/profile'
	failureRedirect: '/login'

router.get '/ok/callback', passport.authenticate 'odnoklassniki',
  successRedirect: '/profile'
  failureRedirect: '/login'

router.get '/activate/:id', (req, res, next) ->
	id = req.params.id

	if req.user
		return next new Error 'Access denied'

	if not id
		return next message: "Пользователь не найден"

	crud.findOne req.params.id, 'profile active', (err, user) ->
		if err
			return next err

		if not user
			return next new Error "User #{req.params.id} not exist"

		if user.active == true
			return res.redirect '../profile'

		user.active = true
		user.activated_at = moment()

		Moneybox.checkReferer req

		user.save (err, user) ->
			if err
				return next new Error 'User has not been activated'

			if not user
				return next new Error 'User does not exist'

			Moneybox.registration user._id, () ->

			data =
				user: user
				activated: true

			req.login user, (err) ->
				return next err if err
				temp = req.session.passport

				req.session.regenerate (err) ->
					return next err if err

					req.session.passport = temp
					req.session.save (err) ->
						return next err if err

						res.redirect '/profile'

router.get '/activate_from_old_site/:email/:password', (req, res, next) ->
	email = req.params.email
	password = req.params.password
	
	if req.user
		return next new Error 'Access denied'
	
	if not email
		return next message: "Пользователь не найден"
	
	if not password
		return next message: "Пароль не найден"
	
	options =
		email: email
		password: MD5 password
	
	Model 'Client', 'findOne', (err, user) ->
		if err
			return next err
		
		if not user
			return next new Error "User #{req.params.email} does not exist"
		
		if user.active == true
			return res.redirect '/profile'
		
		user.active = true
		user.activated_at = moment()
		
		user.save (err, user) ->
			if err
				return next new Error 'User has not been activated'
			
			if not user
				return next new Error 'User does not exist'
			data =
				user: user
				activated: true
			
			req.login user, (err) ->
				return next err if err
				temp = req.session.passport
				
				req.session.regenerate (err) ->
					return next err if err
					
					req.session.passport = temp
					req.session.save (err) ->
						return next err if err
						
						res.redirect '/profile'
	, options

router.get '/already-active', (req, res, next) ->
	View.render 'user/registration/already-active', res

router.get '/success', (req, res, next) ->
	View.render 'user/registration/success', res, message: 'Спасибо за регистрацию'

router.post '/', (req, res, next) ->
	if req.user
		return res.redirect '/profile'

	user = req.body

	user.profile =
		first_name: req.body.firstName

	if not user.password
		return next new Error 'Пароль не указан'

	if user.password.length < 6
		return next new Error 'Пароль маленькой длины'

	if not req.body.firstName
		return next new Error 'Имя не указано'

	if not user.email
		return next new Error 'Почта не указана'

	user.email = user.email.toLowerCase()

	crud.DataEngine 'findOne', (err, fuser) ->
		if err
			return next "Что то пошло не так. Обратитесь к администратору"

		if fuser
			return next "Такой пользователь уже зарегистрирован"

		crud.add user, (err, suser) ->
			if err
				return next "Что то пошло не так. Обратитесь к администратору"

			# console.log suser
			
			activateEmail suser, (err) ->
				if err
					return console.log 'Error:', err
				
				# console.log suser

			res.redirect 'registration/success' 

	, email: user.email

inviteMail = (req, res, friend, callback) ->
	options =
		toName: req.body.firstName
		to: req.body.email
		friend: friend
	
	options.friendName = ' '
	if friend and friend.profile and friend.profile.first_name
		options.friendName += friend.profile.first_name + ' '
	
	options.subject = 'Ваш друг' + options.friendName + 'приглашает вас в сообщество Агуша'
	
	Email.send 'spring_invite', options, callback

router.post '/spring_invite', (req, res) ->
	invited_by = if req.user and req.user._id then req.user._id
	email = req.body.email
	
	client = false
	
	async.waterfall [
		(next) ->
			findOptions =
				email: email
			
			Model 'Client', 'findOne', next, findOptions, '_id invited_emails'
		(doc, next) ->
			if doc
				error = 'Указанный e-mail уже зарегистрирован'
				return View.ajaxResponse res, error
			
			if invited_by
				return Model 'Client', 'findById', next, invited_by, 'profile.first_name'
			
			next null, null
		(doc, next) ->
			if doc
				client = doc
			
			inviteMail req, res, doc, next
		(result, next) ->
			if client
				if !client.invited_emails
					client.invited_emails = []
				
				if !_.contains client.invited_emails, email
					client.invited_emails.push email
					return client.save next
			
			next null
		() ->
			View.ajaxResponse res, null
	], (err) ->
		inviteErr err, res

inviteErr = (err, res) ->
	if err.code == 11000
		error = 'Указанный e-mail уже зарегистрирован'
	else
		error = err.message or err
	
	Logger.log 'info', "Error in controllers/user/signup/invite: #{error}"
	View.ajaxResponse res, error

exports = router

module.exports = exports