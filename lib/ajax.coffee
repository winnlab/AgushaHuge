url = require 'url'

pages = [
	'/login'
	'/logout'
]

exports.isAjax = (req, res, next, layoutPage) ->
	path = url.parse req.path

	if pages.indexOf(path.path) isnt -1
		return next()

	if req.xhr
		return next()

	if layoutPage	
		layoutPage req, res
	else
		next()