async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'

breadcrumbs = require '../../meta/breadcrumbs'

exports.index = (req, res) ->
	phrase = req.params.phrase + ''
	
	if req.params.phrase.indexOf(' ') > -1
		phrase = phrase.replace(/\s+/g, '_')
		return res.redirect '/search/' + phrase
	
	data =
		breadcrumbs: tree.findWithParents breadcrumbs, 'search'
	
	phrase = decodeURI phrase
	phrase = phrase.toLowerCase()
	phrase = phrase.trim()
	
	req.params.phrase = phrase.replace(/_/g, ' ')
	
	res.locals.params = req.params # req.params is not accessable in middlewares -_- 
	
	words = phrase.split '_'
	
	View.render 'user/search/index', res, data