
baseUrl = 'http://localhost:8080/'

linkTo = (relUrl) ->
	if relUrl[0] is '/'
		relUrl = relUrl.substr 1, relUrl.length

	if relUrl[relUrl.length-1] is '/'
		relUrl = relUrl.substr 0, relUrl.length-2

	"#{baseUrl}#{relUrl}"

exports = {
	baseUrl
	linkTo
}

module.exports = exports
