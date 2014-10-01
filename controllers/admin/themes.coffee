Crud = require '../../lib/crud'

class themeCrud extends Crud
	update: (id, data, cb) ->
        async.waterfall [
            (next) =>
                @DataEngine 'findById', next, id
            (doc, next) =>
                unless doc
                    return cb "Cannot find such tale #{id}"
                if doc.age_id.length
                    doc.age_id.splice(0)
                delete data.__v
                _.extend doc, data
                doc.save cb
        ], cb

crud = new Crud
    modelName: 'Theme'
    files: [
        {
            name: 'image'
            replace: true
            type: 'string'
        }
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud