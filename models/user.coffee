mongoose = require 'mongoose'
crypto = require 'crypto'

cryptoUtil = require '../utils/crypto'
timeUtil = require '../utils/time'
validator = require '../utils/validate'

ObjectId = mongoose.Schema.Types.ObjectId

UserShemaFields = 
	username:
		type: String
		required: true
		unique: true
	password:
		type: String
		required: true
		set: cryptoUtil.password
		validate: validator.password
	role:
		type: String
		required: true
		default: 0
		ref: 'Role'
	status:
		type: Number
		default: 0
	active:
		type: Boolean
		default: true
	email:
		type: String,
		required: true
		unique: true
	created_at:
		type: Number
		default: Date.now
	firstName:
		type: String
		required: false
	lastName:
		type: String
		required: false
	title:
		type: String
	text:
		type: String
	photo:
		type: String
	birthday:
		type: Date
		get: timeUtil.getDate
		set: timeUtil.setDate

options =
	collection: 'users'

UserShema = new mongoose.Schema UserShemaFields, options

UserShema.methods.validPassword = (password) ->
	md5pass = crypto.createHash('md5').update(password).digest 'hex'

	isValid = if md5pass == @password then true else false

UserShema.methods.getRole = () ->
	@role || 'user'

module.exports =  mongoose.model 'User', UserShema