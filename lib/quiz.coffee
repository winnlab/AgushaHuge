Model = require './model'

exports.removeOutdated = (doc, _ids, callback) ->
	toRemove = []
	tmp = {}

	for l in _ids
		tmp[l.toString()] = true

	for r in doc.quiz
		unless tmp[r.toString()]
			toRemove.push r

	where = '$or': []

	for item in toRemove
		where['$or'].push _id: item

	proceed = (err) ->
		doc.quiz = _ids
		callback err, doc

	if where['$or'].length
		Model 'QuizAnswer', 'remove', proceed, where
	else
		proceed null