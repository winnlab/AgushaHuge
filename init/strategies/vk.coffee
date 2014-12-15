
config = require '../../config.json'
path = require 'path'
join = path.join

async = require 'async'
request = require 'request'
passport = require 'passport'
_ = require 'lodash'
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
	profileFields: ['photo_100']
	passReqToCallback: true
, (req, accessToken, refreshToken, params, profile, done) ->

	async.waterfall [
		(next) ->
			User.DataEngine 'findOne', next, 'social.vk.id': profile.id
		(user, next) ->
			if req.user
				if user and req.user._id isnt user._id
					return next new Error 'This vk profile already exists'

			if user
				user.auth_from = 'vk'

				return done null, user if user.social.vk.id
				
				user.social.vk =
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken

				return user.save done

			photo = getVkPhoto profile

			User.add
				active: true
				profile:
					first_name: profile.name?.givenName
					last_name: profile.name?.familyName
				social:
					reg_from: 'vk'
					vk:
						id: profile.id
						access_token: accessToken
						refresh_token: refreshToken
				image:
					orig: photo
					large: photo
					medium: photo
					small: photo
			, next
		(user) ->
			Moneybox.registration user._id, () ->

			return done null, user
	], done



getVkPhoto = (profile) ->
	if profile._json?.photo_100
		return profile._json.photo_100
	else
		return profile._json.photo
	

module.exports = exports = {};

