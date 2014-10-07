async = require 'async'
_ = require 'lodash'
Model = require '../../lib/mongooseTransport'

Crud = require '../../lib/crud'
objUtils = require '../../utils/object'

class TypeCrud extends Crud
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
                    Model 'Article', 'update', {'type.name': oldVal}, {'type.name': newVal}, {multi: true}, cb
                else
                    cb null, doc
        ], cb

crud = new TypeCrud
    modelName: 'ArticleType'

module.exports.rest = crud.request.bind crud