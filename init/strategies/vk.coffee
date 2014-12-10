
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
	profileFields: ['email']
	passReqToCallback: true
, (req, accessToken, refreshToken, params, profile, done) ->
	async.waterfall [
		(next) ->
			###
			#	Step 1. Find user by his profile id
			###

			User.DataEngine 'findOne', next, 'social.vk.id': profile.id
		(user, next) ->
			###
			#	Step 2. Find user by email from profile
			###


			email = params.email.toLowerCase().toString()

			if req.user
				if user and req.user._id isnt user._id
					return next new Error 'This vk profile already exist'

				email = req.user.email

			User.DataEngine 'findOne', next, 'email': email
		(user, next) ->
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

