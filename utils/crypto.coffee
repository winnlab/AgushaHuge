crypto = require 'crypto'

exports.md5 = md5 = (string)->
	return crypto.createHash('md5').update(string).digest 'hex'

exports.password = (string)->
	return md5 string