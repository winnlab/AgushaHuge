async = require 'async'
_ = require 'underscore'
moment = require 'moment'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'
string = require '../../utils/string'

breadcrumbs = require '../../meta/breadcrumbs'

springRegistrationWinners = require '../../meta/springRegistrationWinners'

winners_array = [
	date: '21.05.2015'
	data:
		winners: springRegistrationWinners
]

getWinners = (winners_item, callback) ->
	winners = winners_item.data
	
	fields = '_id profile.first_name profile.middle_name profile.last_name image.medium children.gender'
	
	sortOptions =
		lean: true
	
	options =
		$or: []
	
	lng = winners.winners.length
	while lng--
		winner = winners.winners[lng]
		options.$or.push
			email: winner
	
	Model 'Client', 'find', options, fields, sortOptions, callback

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
	
	async.waterfall [
		(next) ->
			async.map winners_array, getWinners, next
		(results, next) ->
			data.winners = []
			
			resultsLength = results.length
			while resultsLength--
				result = results[resultsLength]
				data.winners[resultsLength] =
					date: winners_array[resultsLength].date
					data: result
			
			View.render 'user/springregistration/index', res, data
	], (err) ->
		error = err.message or err
		Logger.log 'info', "Error in controllers/user/springregistration/index: #{error}"

exports.success = (req, res) ->
	res.redirect '/springregistration'