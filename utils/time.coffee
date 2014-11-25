moment = require 'moment'

exports.startOf = (label, day, format)->
	label = label || 'week'
	format = format || 'XSSS'

	moment().startOf(label).format format

exports.endOf = (label, day, format)->
	label = label || 'week'
	format = format || 'XSSS'

	moment().endOf(label).format format

exports.today = (format) ->
	moment().format format

exports.getDate = (val) ->
	if not val
		return val
	
	return moment(val).format('DD/MM/YYYY')

exports.setDate = (val) ->
	if not val
		return val
	
	return moment(val, 'DD/MM/YYYY').format('MM/DD/YYYY')