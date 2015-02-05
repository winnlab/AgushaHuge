async = require 'async'

passport = require 'passport'
localStrategy = require('passport-local').Strategy

fbStartegy = require './strategies/fb'
vkStartegy = require './strategies/vk'
okStartegy = require './strategies/ok'

mongoose = require 'mongoose'

Model = require '../lib/model'

parameters =
	usernameField: 'username'
	passwordField: 'password'

parameters2 =
	usernameField: 'email'
	passwordField: 'password'

passport.serializeUser (user, done) ->
	done null, user.id

passport.deserializeUser (id, done) ->
	async.parallel
		client: (next) ->
			Model 'Client', 'findOne', next, _id : id
		user: (next) ->
			Model 'User', 'findOne', next, _id : id
	, (err, results) ->
		if err
			return done err

		done null, results.client || results.user

callbackToValidation = (username, password, done, err, user) ->
	validation err, user, password, done

validation = (err, user, password, done) ->
	if err
		return done message: err.message
	
	console.log user
	
	if not user
		return done message: 'Пользователь с таким именем не существует!'

	if not user.active
		return done message: 'Пользователь не активирован'

	if not user.validPassword password
		return done message: 'Пароль введен неправильно.'

	done null, user

adminStrategy = (username, password, done) ->
	username = username.toLocaleLowerCase()
	
	Model 'User', 'findOne', 
		async.apply(callbackToValidation, arguments...), {username : username}

userStrategy = (email, password, done) ->
	email = email.toLocaleLowerCase()
	
	Model 'Client', 'findOne',
		async.apply(callbackToValidation, arguments...), {email : email}

exports.init = (callback) ->
	adminAuth = new localStrategy adminStrategy
	clientAuth = new localStrategy parameters2, userStrategy

	passport.use 'admin', adminAuth
	passport.use 'user', clientAuth

	callback()