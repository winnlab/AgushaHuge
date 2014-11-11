async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'
Article = require '../../lib/article'
Consultation = require '../../lib/consultation'

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
	
	async.parallel
		articles: (next) ->
			Article.search words, next
		consultations: (next) ->
			Consultation.search words, next
	, (err, results) ->
		if err
			error = err.message or err
			Logger.log 'info', "Error in controllers/user/search/index: #{error}"
			return res.send error
		
		console.log results
	
		View.render 'user/search/index', res, data