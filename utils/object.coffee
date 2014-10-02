async = require 'async'
_ = require 'lodash'

exports.handleProperty = (obj, property, value) ->
	string = ''
	parts = property.split '.'

	for part in parts
		string += "['#{part}']"

	del = if typeof value is 'string' then "'" else ""
	eval "obj#{string}=#{del}#{value}#{del};" if value isnt undefined

	eval "var result = obj#{string};"
	return result