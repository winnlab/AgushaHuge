async = require 'async'
_ = require 'lodash'

Crud = require '../../lib/crud'

class AgeCrud extends Crud
	add: (data, cb) ->
		next = (err, data) ->
			cb err, _id: data?._id
		DocModel = @DataEngine()
		doc = new DocModel data
		doc.desc =
			title: data['desc.title']
			subtitle: data['desc.subtitle']
			text: data['desc.text']
			tagline: data['desc.tagline']

		doc.save next

	update: (id, data, cb) ->
		data.desc =
			title: data['desc.title']
			subtitle: data['desc.subtitle']
			text: data['desc.text']
			tagline: data['desc.tagline']

		async.waterfall [
			(next) =>
				@DataEngine 'findById', next, id
			(doc, next) =>
				_.extend doc, data
				doc.save cb
		], cb

crud = new AgeCrud
    modelName: 'Age'
    files: [
        name: 'icon.normal'
        replace: true
        type: 'string'
    ,
        name: 'icon.hover'
        replace: true
        type: 'string'
    ,
        name: 'desc.image.normal'
        replace: true
        type: 'string'
    ,
        name: 'desc.image.expanded'
        replace: true
        type: 'string'
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud