exports.strip_tags = (str) ->
	str.replace /<\/?[^>]+>/g, ' '

exports.title_case = (str) ->	
	if not str or str == ''
		return str
	
	str = str.replace(RegExp(' +', 'g'), ' ')
	str = str.split(' ')
	
	k = str.length;
	while(k--)
		str[k] = str[k].slice(0, 1).toLocaleUpperCase() + str[k].slice(1).toLocaleLowerCase()
	
	str.join(' ')

exports.escape = (text) ->
	text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')

exports.leftPad = (number, targetLength) ->
	output = number + ''
	while output.length < targetLength
		output = '0' + output
	output