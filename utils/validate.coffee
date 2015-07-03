exports.password = (pass) ->
	if (pass.length > 0) then true else false
	
exports.email = (val) ->
	regexp = /^([a-zA-Z\.\_\-]{1,})@([a-zA-Z\.\_\-]{1,})\.(.*)$/
	regexp.test val