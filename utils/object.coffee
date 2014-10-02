async = require 'async'
_ = require 'lodash'

exports.handleProperty = (obj, property, value) ->
	elems = property.split '.'
 
	if elems.length < 2
		obj[elems[0]] = value if value isnt undefined
		return obj[elems[0]]

	obj[elems[0]] = {} if not obj[elems[0]]

	exports.handleProperty obj[elems.shift()], elems.join("."), value