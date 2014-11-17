
crypto = require 'crypto'

moment = require 'moment'
mongoose = require 'mongoose'
_ = require 'underscore'

ObjectId = mongoose.Schema.Types.ObjectId
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
		gender:
			type: Number
	birth_date:
		month:
			type: Number
			default: null
		day:
			type: Number
			default: null

		year:
			type: Number
			default: null
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
		spareEmail:
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
		# child_id:
		# 	type: ObjectId
		# 	ref: 'Children'
		photo:
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
				set: (value) ->
					parseInt value
			month:
				type: String
				set: (value) ->
					parseInt value
			year:
				type: String
				set: (value) ->
					parseInt value
	]
	points:
		type: Number
		default: 0
,
	collection: 'client'

schema.pre 'save', (next) ->
	@profile.filling = @fillingProfile()

	next()

schema.methods.name = () ->
	"#{@first_name} #{@last_name}"

schema.methods.lvl = () ->
	grade = switch
	  when @points < 200 then 'Новичек'
	  when @points < 400 then 'Ученик'
	  when @points < 600 then 'Знаток'
	  when @points < 800 then 'Эксперт'
	  else 'Профи'

schema.methods.fillingProfile = () ->
	def = 0
	that = @

	_.each metaFillingWeight, (weightItem, key) ->
		fields = weightItem.fields

		isFill = _.every fields, (field) ->
			return that.get field

		if isFill
			def += weightItem.weight

	return def

schema.methods.getImage = (type) ->
	return ''

schema.methods.validPassword = (password) ->
	md5pass = crypto.createHash('md5').update(password).digest 'hex'

	isValid = if md5pass == @password then true else false

module.exports = mongoose.model 'Client', schema
