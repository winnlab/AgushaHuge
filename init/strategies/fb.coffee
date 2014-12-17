
join = require('path').join

async = require 'async'
passport = require 'passport'
FaseBookStrategy = require 'passport-facebook'

Crud = require('../../lib/crud')
Moneybox = require '../../lib/moneybox'

locals = require('../locals').site

User = new Crud
	modelName: 'Client'

gender = 0

passport.use 'facebook', new FaseBookStrategy
	clientID: 812840382107432,
	clientSecret: "2d82f2e09e4c47eb9a4d5e5b8e614700",
	callbackURL: locals.linkTo('registration/fb/callback')
	profileFields: ['id', 'name', 'picture.height(200).width(200)', 'emails',],
	passReqToCallback: true
, (req, accessToken, refreshToken, profile, done) ->

	if req.user
		linkFacebook req, accessToken, refreshToken, profile, done
	else
		async.waterfall [
			(next) ->
				User.DataEngine 'findOne', next, 'social.fb.id': profile.id
			(user, next) ->
				if user
					if req.user and req.user._id isnt user._id
						return done new Error 'This fb profile already exist'

					if user.social?.fb?.id is profile.id
						return done null, user

				email = profile['_json'].email?.toString().toLowerCase() or ''

				if req.user
					email = req.user.email

				User.DataEngine 'findOne', next, 'email': email
			(user, next) ->
				if user
					user.auth_from = 'fb'

					return done null, user if user.social.fb?.id

					user.social.fb =
						id: profile.id
						access_token: accessToken
						refresh_token: refreshToken

					return user.save done

				next()
			(next) ->
				User.add
					email: profile['_json'].email
					active: true
					profile:
						first_name: profile.name?.givenName
						last_name: profile.name?.familyName
					social:
						reg_from: 'fb'
						fb:
							id: profile.id
							access_token: accessToken
							refresh_token: refreshToken
					image:
						orig: profile.photos?[0].value
						large: profile.photos?[0].value
						medium: profile.photos?[0].value
						small: profile.photos?[0].value
				, next
			(user, next) ->

				Moneybox.registration user._id, () ->

				done null, user
		], done

linkFacebook = (req, accessToken, refreshToken, profile, done) ->
	async.waterfall [
		(next) ->
			User.DataEngine 'findOne', next, _id: req.user._id
		(doc, next) ->
			if doc
				doc.social.fb = {
					id: profile.id
				}

				doc.save next
		(user, next) ->
			done null, user
	], done

module.exports = exports = {};
