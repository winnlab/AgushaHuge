_ = require 'underscore'

exports.setPropertyByIntersection = (real, all, field = '_id', prop = 'exists', val = true) ->
	return if real is undefined or real.length is 0

	for aItem in all
		vItem = aItem[field] || aItem
		for eItem in real

			if _.isObject(vItem) and not _.isArray vItem
				equals = _.isEqual vItem, eItem
			else
				equals = vItem is eItem

			if equals
				aItem[prop] = val
				break