exports.password = (pass) ->
	if (pass.length > 0) then true else false
	
exports.email = (val) ->
	regexp = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
	regexp.test val