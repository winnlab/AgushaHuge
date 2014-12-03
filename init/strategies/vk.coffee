
config = require '../../config.json'
path = require 'path'
join = path.join

async = require 'async'
request = require 'request'
passport = require 'passport'
VkontakteStrategy = require('passport-vkontakte').Strategy

Crud = require('../../lib/crud')
Moneybox = require '../../lib/moneybox'

locals = require('../locals').site

User = new Crud
	modelName: 'Client'

passport.use 'vkontakte', new VkontakteStrategy
	clientID: config.vk.APP_ID,
	clientSecret: config.vk.CLIENT_SECRET,
	callbackURL: locals.linkTo('registration/vk/callback')
	profileFields: ['photo_400_orig', 'bdate', 'photo_max', 'city']
	passReqToCallback: true
, (req, accessToken, refreshToken, params, profile, done) ->
	async.waterfall [
		(next) ->
			###
			#	Step 1. Find user by his profile id
			###
			console.info "Step 1"
			User.DataEngine 'findOne', next, 'social.vk.id': profile.id
		(user, next) ->
			###
			#	Step 2. Find user by email from profile
			###
			console.info "Step 2"


			email = params.email.toLowerCase().toString()

			if req.user
				if user and req.user._id isnt user._id
					return next new Error 'This vk profile already exist'

				email = req.user.email

			profile.birthday = profile.birthday.split '-'

			dates =
				day: profile.birthday[2]
				month: profile.birthday[1]
				year: profile.birthday[0]

			User.DataEngine 'findOne', next, 'email': email
		(user, next) ->
			console.info "Step 3"

			if user
				user.auth_from = 'vk'

				return done null, user if user.social.vk.id
				
				user.social.vk =
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken

				return user.save done

			User.add
				email: params.email.toLowerCase()
				active: true
				# image: profile['_json'].photo_max
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
			, next
		(user) ->
			console.info "Step 4"

			Moneybox.registration user._id, () ->
			

			return done null, user
	], done
	

module.exports = exports = {};

