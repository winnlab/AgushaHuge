
async = require 'async'
moment = require 'moment'

router = require('express').Router()

Crud = require '../../lib/crud'
View = require '../../lib/view'
Model = require '../../lib/model'
Email = require '../../lib/mail'

crud = new Crud
	modelName: 'Client'

activateEmail = (user, callback) ->
	emailMeta =
		toName: "#{user.profile.first_name} #{user.profile.last_name}"
		to: user.email
		subject: "Активация аккаунта на agusha.com.ua"
		user: user

	Email.send 'registration', emailMeta, callback


router.get '/', (req, res, next) ->
	View.render 'user/registration/index', res

router.get '/activate/:id', (req, res, next) ->
	id = req.params.id

	if not id
		return next new Error "Пользователь не найден"

	crud.findOne req.params.id, 'profile active', (err, user) ->
		if err
			return next err

		if not user
			return next new Error "User #{req.params.id} not exist"

		if user.active
			return res.redirect '../already-active'

		user.active = true
		user.activated_at = moment()

		user.save (err, user) ->
			data =
				user: user
				activated: true

			console.log "User #{user._id}, has been activated"

			View.render 'user/registration/success', res, data

router.get '/already-active', (req, res, next) ->
	View.render 'user/registration/already-active', res

router.get '/success', (req, res, next) ->
	View.render 'user/registration/success', res, message: 'Спасибо за регистрацию'

router.post '/', (req, res, next) ->
	user = req.body

	if not user.password
		return next new Error 'Password not exist'

	if not user.firstname
		return next new Error "Firstname not exist"

	if not user.lastname
		return next new Error "Lastname not exist"

	user.profile =
		first_name: user.firstname
		last_name: user.lastname

	crud.add user, (err, suser) ->
		if err
			return next new Error 'User not created. Please try again later'

		activateEmail suser, (err) ->
			if err
				return console.log 'Error:', err

			console.log "User #{suser._id}, #{suser.profile.firstname} #{suser.profile.lastname} has been registered"

		res.redirect 'registration/success' 

exports = router

module.exports = exports
