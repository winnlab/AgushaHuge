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

exports.makeTreeForSelect = (array, nameField = 'name', levelField = '_level') ->
	for item in array
		if not item.pid
			item[levelField] = 0
		else
			parent = _.find array, (el) ->
				return el._id.toString() is item.pid.toString()

			item[levelField] = if parent then parent[levelField] + 1 else 0
			if item[nameField]
				prefix = ''
				for i in [0...item[levelField]]
					prefix += '-'
				item[nameField] = prefix + item[nameField]


	return array