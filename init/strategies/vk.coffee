
path = require 'path'
join = path.join

request = require 'request'
passport = require 'passport'
VkontakteStrategy = require('passport-vkontakte').Strategy

Crud = require('../../lib/crud')

locals = require('../locals').site

User = new Crud
	modelName: 'Client'

passport.use 'vkontakte', new VkontakteStrategy
	clientID: 4581691,
	clientSecret: "AiXIURFGjfwzdXt3sArc",
	callbackURL: locals.linkTo('registration/vk/callback')
	profileFields: ['photo_400_orig', 'bdate', 'photo_max', 'city']
	passReqToCallback: true
, (req, accessToken, refreshToken, params, profile, done) ->
	params.email = params.email.toLowerCase().toString()

	profile.birthday = profile.birthday.split '-'

	dates =
		day: profile.birthday[2]
		month: profile.birthday[1]
		year: profile.birthday[0]

	callback = (err, user) ->
		if err
			return done err

		if user
			user.auth_from = 'vk'
			if not user.social.vk
				user.vk =
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken
				return user.save done

			return user.save done

		User.create
			email: params.email.toLowerCase()
			active: true
			image: profile['_json'].photo_max
			profile:
				first_name: profile.name.givenName
				last_name: profile.name.familyName
				gender: profile['_json'].sex
				birth_date: dates
			social:
				reg_from: 'vk'
				vk:
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken
		, (err, user) ->
			if err
				return done err

			return done null, user

	User.DataEngine 'findOne', callback, 'email': params.email, 

module.exports = exports = {};

