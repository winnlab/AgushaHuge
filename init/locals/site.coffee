
baseUrl = 'http://agusha.com.ua:8080/'

linkTo = (relUrl) ->
	if relUrl[0] is '/'
		relUrl = rel.substr 1, relUrl.length

	if relUrl[relUrl.length-1] is '/'
		relUrl = rel.substr 0, relUrl.length-2

	"#{baseUrl}#{relUrl}"

exports = {
	baseUrl
	linkTo
}

module.exports = exports
