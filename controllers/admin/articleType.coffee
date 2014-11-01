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
                    where = 'type.name': oldVal
                    what = 'type.name': newVal
                    opts = multi: true
                    async.waterfall [
                        (next) ->
                            Model 'Article', 'update', where, what, opts, next
                        (affected, raw, next) ->
                            Model 'Consultation', 'update', where, what, opts, next
                        () ->
                            cb null, doc
                    ], cb
                else
                    cb null, doc
        ], cb

crud = new TypeCrud
    modelName: 'ArticleType'
    denormalized: [
        property: 'name'
        _id: 'name'
        denormalizedIn: [
            model: 'Article'
            path: 'type'
            _id: 'name'
            multiple: false
        ,
            model: 'Consultation'
            path: 'type'
            _id: 'name'
            multiple: false
        ]
    ]

module.exports.rest = crud.request.bind crud