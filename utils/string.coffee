exports.strip_tags = (str) ->
	str.replace /<\/?[^>]+>/g, ' '

exports.title_case = (str) ->
	first = str.charAt(0).toUpperCase()
	rest = (str.substr 1, str.length - 1).toLowerCase()
	
	first + rest

exports.escape = (text) ->
	text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')