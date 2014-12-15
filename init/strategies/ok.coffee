passport = require 'passport'
OkStrategy = require('passport-odnoklassniki').Strategy
async = require 'async'

locals = require('../locals').site

Crud = require('../../lib/crud')
Moneybox = require '../../lib/moneybox'

User = new Crud
	modelName: 'Client'

passport.use 'odnoklassniki', new OkStrategy
	clientID: "1112713728",
	clientPublic: 'CBALKDFDEBABABABA',
	clientSecret: 'CCC0ADF3388AB4C6EE7F09DC',
	callbackURL: locals.linkTo('registration/ok/callback')
, (accessToken, refreshToken, profile, done) ->

	async.waterfall [
		(next) ->
			User.DataEngine 'findOne', next, 'social.ok.id': profile.id
		(user, next) ->
			return done null, user if user?.social?.ok?.id is profile.id

			if user
				user.auth_from = 'ok'

				return done null, user if user.social.fb?.id

				user.social.ok =
					id: profile.id
					access_token: accessToken
					refresh_token: refreshToken

				return user.save done

			next()
		(next) ->
			photo = getPhoto profile.photos

			User.add
				email: profile.emails?[0]
				active: true
				profile:
					first_name: profile.name?.givenName
					last_name: profile.name?.familyName
				social:
					reg_from: 'ok'
					ok:
						id: profile.id
						access_token: accessToken
						refresh_token: refreshToken
				image:
					orig: photo
					large: photo
					medium: photo
					small: photo
			, next
		(user, next) ->

			Moneybox.registration user._id, () ->

			done null, user
	], done


getPhoto = (photos) ->
	return '' unless photos?[0].value

	photos?[0].value.replace 'photoType=4', 'photoType=5'

module.exports = exports = {};
