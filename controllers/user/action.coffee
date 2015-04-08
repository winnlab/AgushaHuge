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
	currentDate = moment()
	endDate = moment '20.04.2015', 'DD.MM.YYYY'
	diff = endDate.diff currentDate
	
	duration = moment.duration diff
	
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'action'
		duration:
			days: _.chars string.leftPad duration._data.days, 2
			hours: _.chars string.leftPad duration._data.hours, 2
			minutes: _.chars string.leftPad duration._data.minutes, 2
	
	View.render 'user/action/index', res, data