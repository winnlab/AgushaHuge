
crypto = require 'crypto'

moment = require 'moment'
mongoose = require 'mongoose'
_ = require 'underscore'

ObjectId = mongoose.Schema.Types.ObjectId

Moneybox = require '../lib/moneybox'
Validate = require '../utils/validate'

cryptoUtil = require '../utils/crypto'
validator = require '../utils/validate'

metaFillingWeight = require '../meta/profileWeight.coffee'

schema = new mongoose.Schema
	email:
		type: String
		trim: true
		unique: true
		sparse: true
		validate: Validate.email
	spareEmail:
		type: String
		default: null
	created_at:
		type: Date
		default: moment
	activated_at:
		type: Date
	last_activity_at:
		type: Date
	active:
		type: Boolean
		default: false
	password:
		type: String
		set: cryptoUtil.password
		validate: validator.password
	agree:
		type: Boolean
		default: false
	login: # old field after merging databases
		type: String
	type: # 0 - direct, 1 - friend
		type: Number
		default: 0
	invited_by:
		type: ObjectId
		ref: 'Client'
	invited_emails: [
		type: String
	]
	hasKids: # 0 - does not have, 1 - has, 2 - is waiting # old field after merging databases
		type: Number
	ip_address: # old field after merging databases
		type: String
	profile:
		about:
			type: String
		filling:
			type: Number
			default: 0
		first_name:
			type: String
			trim: true
		last_name:
			type: String
			trim: true
		middle_name:
			type: String
			trim: true
		gender:
			type: Number
	birth_date:
		month:
			type: Number
			default: 0
		day:
			type: Number
			default: 0

		year:
			type: Number
			default: 0
	contacts:
		country:
			type: String
			default: null
		city:
			type: String
			default: null
		street:
			type: String
			default: null
		houseNum:
			type: String
			default: null
		apartament:
			type: String
			default: null
		phone:
			type: String
			default: null
		postIndex:
			type: String
			default: null
	image:
		orig:
			type: String
		large:
			type: String
		medium:
			type: String
		small:
			type: String
	social:
		vk:
			id:
				type: String
			access_token:
				type: String
			refresh_token:
				type: String
		fb:
			id:
				type: String
			access_token:
				type: String
			refresh_token:
				type: String
		ok:
			id:
				type: String
			access_token:
				type: String
			refresh_token:
				type: String
	children: [
		image:
			large:
				type: String
			small:
				type: String
		gender:
			type: Number
			default: 0
		name:
			type: String
		birth_date:
			type: Date
		birth:
			day:
				type: String
				default: 0
				set: (value) ->
					parseInt value
			month:
				type: String
				default: 0
				set: (value) ->
					parseInt value
			year:
				type: String
				default: 0
				set: (value) ->
					parseInt value
	]
	points:
		type: Number
		default: 0
,
	collection: 'client'
	versionKey: false

schema.virtual('has_password')
	.get () ->
		if @password then true else false

schema.pre 'save', (next) ->
	that = @
	@fillingProfile (filling) ->
		that.profile.filling = filling
		next()

schema.methods.name = () ->
	"#{@first_name} #{@last_name}"

schema.methods.fillingProfile = (cb) ->
	def = 0
	that = @

	_.each metaFillingWeight, (weightItem, key) ->
		fields = weightItem.fields

		isFill = _.every fields, (field) ->
			return that.get field

		if isFill
			def += weightItem.weight

	if def == 100
		return Moneybox.profile @_id, () ->
			cb def

	cb def

schema.methods.getImage = (type) ->
	return ''

schema.methods.validPassword = (password) ->
	md5pass = crypto.createHash('md5').update(password).digest 'hex'

	isValid = if md5pass == @password then true else false

schema.methods.getRole = () ->
	@role || 'user'

module.exports = mongoose.model 'Client', schema
