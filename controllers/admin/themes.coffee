async = require 'async'
_ = require 'lodash'
Model = require '../../lib/mongooseTransport'

Crud = require '../../lib/crud'
objUtils = require '../../utils/object'

class ThemeCrud extends Crud
    update: (id, data, cb) ->
        oldVal = null
        async.waterfall [
            (next) =>
                @DataEngine 'findById', next, id
            (doc, next) =>
                oldVal = doc.name
                for own field, value of data
                    objUtils.handleProperty doc, field, value
                doc.save next
            (doc) ->
                newVal = doc.name
                if oldVal isnt newVal
                    Model 'Article', 'update', {'theme.theme_id': doc._id}, {'theme.name': newVal}, {multi: true}, cb
                else
                    cb null, doc
        ], cb

crud = new ThemeCrud
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