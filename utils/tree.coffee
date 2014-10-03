_ = require 'underscore'

addParents = (result, tree, page) ->
	if page.parent_id
		parent = _.find tree, (item) ->
			item.id == page.parent_id
		
		result.push parent
		
		addParents result, tree, parent
	else
		return

exports.findWithParents = (tree, name) ->
	result = []
	
	page = _.find tree, (item) ->
		item.id == name
	
	result.push page
	
	addParents result, tree, page
	
	result.reverse()