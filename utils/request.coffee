exports.is_ajax_request = is_ajax_request = (headers) ->
	headers["x-requested-with"] is "XMLHttpRequest"