
join = require('path').join

passport = require 'passport'
FaseBookStrategy = require 'passport-facebook'

Crud = require('../../lib/crud')

locals = require('../locals').site

User = new Crud
	modelName: 'Client'

gender = 0

passport.use 'facebook', new FaseBookStrategy
	clientID: 812840382107432,
	clientSecret: "2d82f2e09e4c47eb9a4d5e5b8e614700",
	callbackURL: locals.linkTo('registration/fb/callback')
	profileFields: ['birthday', 'gender', 'email', 'first_name', 'last_name', 'picture.type(square)']
	passReqToCallback: true
, (req, accessToken, refreshToken, profile, done) ->
	dates = {}

	profile['_json'].email = profile['_json'].email.toString().toLowerCase()
	if profile['_json'].gender
		gender = if profile['_json'].gender is 'male' then 2 else 1

	if profile['_json'].birthday
		profile['_json'].birthday = profile['_json'].birthday.split '/'

		dates =
			day: profile['_json'].birthday[0]
			month: profile['_json'].birthday[2]
			year: profile['_json'].birthday[1]

	callback = (err, user) ->
		if err
			return done err

		if user
			user.auth_from = 'fb'
			if not user.social.fb
				user.fb =
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken
				return user.save done
			user.save ->

			return done null, user

		User.add
			email: profile['_json'].email
			image: profile['_json'].picture.data.url
			profile:
				first_name: profile.name.givenName
				last_name: profile.name.familyName
				birth_date: dates
				gender: gender
			active: true
			social:
				reg_from: 'fb'
				fb:
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken
		, (err, user) ->
			if err
				return done err

			done null, user

	User.DataEngine 'findOne', callback, 'email': profile['_json'].email

module.exports = exports = {};

