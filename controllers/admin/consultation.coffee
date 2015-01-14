async = require 'async'
mongoose = require 'mongoose'
_ = require 'lodash'

Crud = require '../../lib/crud'
Model = require '../../lib/mongooseTransport'

objUtils = require '../../utils/object.coffee'
hprop = objUtils.handleProperty

class ConsultationCrud extends Crud
	add: (data, cb) ->
		DocModel = @DataEngine()
		doc = new DocModel()

		for own field, value of data
			hprop doc, field, value

		async.waterfall [
			(next) ->
				doc.save next
			(doc, numberAffected, next) ->
				unless doc.theme or doc.theme.length isnt 0 or doc.encyclopedia
					return do next

				where =
                    _id:
                        $in: _.pluck doc.theme, '_id'
                what =
                    $inc:
                        'counter.article': 1

                Model 'Theme', 'update', where, what, {multi: true}, next
		], (err) ->
			cb err, unless err then doc else undefined

	update: (id, data, cb) ->
		oldVals = []
		for item in @options.denormalized
			oldVals[item.property] = null

		oldThemes = []
		oldEncyc = undefined
		async.waterfall [
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				for item in @options.denormalized
					value = hprop doc, item.property
					hprop oldVals, item.property, value

				oldEncyc = doc.encyclopedia
				oldThemes = _.pluck doc.theme, '_id'
				oldThemes = _.map oldThemes, (v) -> v?.toString?()

				unless data.answer
					data.answer = []

				for own field, value of data
					hprop doc, field, value

				@sendNotificationToClient data.answer, doc

				doc.save next
			(doc, numberAffected, next) =>
				newEncyc = doc.encyclopedia
				if newEncyc
					newThemes = _.pluck doc.theme, '_id'
					newThemes = _.map newThemes, (v) -> v?.toString()

				if newEncyc and oldEncyc
					toIncrease = _.difference newThemes, oldThemes
					toDecrease = _.difference oldThemes, newThemes
				else if newEncyc and not oldEncyc
					toIncrease = newThemes
				else if not newEncyc and oldEncyc
					toDecrease = oldThemes

				async.parallel
					decrease: (next) ->
						toDecrease = _.map toDecrease, (v) -> mongoose.Types.ObjectId v

						return do next unless toDecrease.length

						where =
							_id:
								$in: toDecrease
						what =
							$inc:
								'counter.article': -1

						Model 'Theme', 'update', where, what, {multi: true}, next
					increase: (next) ->
						toIncrease = _.map toIncrease, (v) -> mongoose.Types.ObjectId v

						return do next unless toIncrease.length

						where =
							_id:
								$in: toIncrease
						what =
							$inc:
								'counter.article': 1

						Model 'Theme', 'update', where, what, {multi: true}, next
				, (err, results) =>
					if @options.denormalized.length
						return next err, doc

					cb err, doc
			(doc) =>
				@_updateDenormalized oldVals, doc, cb
		], cb

	remove: (id, cb) ->
		async.waterfall [
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				@_removeDocFiles doc, (err) ->
					next err, doc
			(doc, next) ->
				doc.remove (err) ->
					next err, doc
			(doc, next)  ->
				unless doc.encyclopedia
					return cb null, doc

				where =
                    _id:
                        $in: _.pluck doc.theme, '_id'
                what =
                    $inc:
                        'counter.article': -1

                Model 'Theme', 'update', where, what, {multi: true}, (err) ->
                    cb err, doc
		], cb

	sendNotificationToClient: (dataAnswers, externalDoc) ->
		if dataAnswers
			newAnswers = _.filter dataAnswers, (element) ->
				return element._id is undefined

			if newAnswers and externalDoc.author?.author_id

				async.waterfall [
					(next) ->
						Model 'Conversation', 'findOne', {
							'interlocutors.client': externalDoc.author.author_id,
							'interlocutors.client': newAnswers[0].specialist._id
						}, next

					(doc, next) =>

						if doc
							authorIndex = _.findIndex doc.interlocutors, (interlocutor) ->
								return interlocutor.client.toString() is externalDoc.author.author_id.toString()

							doc.interlocutors[authorIndex].read = false
						else
							DocModel = Model 'Conversation'
							doc = new DocModel()

							doc.interlocutors = [
								client: externalDoc.author.author_id
							,
								client: newAnswers[0].specialist._id
							]
							doc.type = 'consultation'

						for answer in newAnswers
							trimmedText = answer.text.substr 0, 30
							trimmedText = trimmedText.substr(0, Math.min(trimmedText.length, trimmedText.lastIndexOf(" ")))
							trimmedText += '...'

							unless doc.messages
								doc.messages = []

							doc.messages.push {
								author: answer.specialist._id,
								title: externalDoc.name,
								content: 'Доктор ответил на Ваш вопрос "' + externalDoc.name + '" в теме "' + externalDoc.theme[0].name + '" <br><br>' + 'Ответ доктора:<br>' + trimmedText + '<br><br><a href="question/' + externalDoc.transliterated + '">продолжить диалог</a>'
							}
							doc.updated = answer.date

						doc.save next

					(doc, next) ->

				], (err) ->
					console.error err



crud = new ConsultationCrud
	modelName: 'Consultation'

module.exports.rest = crud.request.bind crud
