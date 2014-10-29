async = require 'async'
_ = require 'lodash'
Model = require '../../lib/mongooseTransport'

Crud = require '../../lib/crud'
objUtils = require '../../utils/object'

class AgeCrud extends Crud
    update: (id, data, cb) ->
        oldVal = null
        async.waterfall [
            (next) =>
                @DataEngine 'findById', next, id
            (doc, next) =>
                oldVal = doc.title
                for own field, value of data
                    objUtils.handleProperty doc, field, value
                doc.save next
            (doc) ->
                newVal = doc.title
                if oldVal isnt newVal
                    where = 'age.age_id': doc._id
                    what = 'age.title': newVal
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