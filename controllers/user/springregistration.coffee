async = require 'async'
_ = require 'underscore'
moment = require 'moment'

View = require '../../lib/view'
Product = require '../../lib/product'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'
string = require '../../utils/string'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	# currentDate = moment()
	# endDate = moment '21/05/2015', 'DD/MM/YYYY'
	# diff = endDate.diff currentDate
	
	# duration = moment.duration diff
	
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'springregistration'
		# duration:
			# days: _.chars string.leftPad duration._data.days + (if duration._data.months > 0 then 30 else 0), 2
			# hours: _.chars string.leftPad duration._data.hours, 2
			# minutes: _.chars string.leftPad duration._data.minutes, 2
	
	View.render 'user/springregistration/index', res, data

exports.success = (req, res) ->
	res.redirect '/springregistration'