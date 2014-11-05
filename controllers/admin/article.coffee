async = require 'async'
mongoose = require 'mongoose'
_ = require 'lodash'

Crud = require '../../lib/crud'
Model = require '../../lib/mongooseTransport'

objUtils = require '../../utils/object.coffee'
hprop = objUtils.handleProperty

class ArticleCrud extends Crud
    add: (data, cb) ->
        DocModel = @DataEngine()
        doc = new DocModel()

        for own field, value of data
            hprop doc, field, value

        async.waterfall [
            (next) ->
                doc.save next
            (doc, numberAffected, next) ->
                unless doc.theme or doc.theme.length isnt 0
                    return do next

                where = 
                    _id:
                        $in: _.pluck doc.theme, '_id'
                what =
                    $inc:
                        'counter.article': 1

                Model 'Theme', 'update', where, what, {multi: true}, next
        ], (err) ->
            cb err, data

    update: (id, data, cb) ->
        oldVals = []
        for item in @options.denormalized
            oldVals[item.property] = null

        oldThemes = []
        async.waterfall [
            (next) =>
                @DataEngine 'findById', next, id
            (doc, next) =>
                for item in @options.denormalized
                    value = hprop doc, item.property
                    hprop oldVals, item.property, value

                oldThemes = _.pluck doc.theme, '_id'
                oldThemes = _.map oldThemes, (v) -> v?.toString()

                for own field, value of data
                    hprop doc, field, value

                doc.save next
            (doc, numberAffected, next) =>
                newThemes = _.pluck doc.theme, '_id'
                newThemes = _.map newThemes, (v) -> v?.toString()

                async.parallel
                    decrease: (next) ->
                        toDecrease = _.difference oldThemes, newThemes
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
                        toIncrease = _.difference newThemes, oldThemes
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
                where = 
                    _id:
                        $in: _.pluck doc.theme, '_id'
                what =
                    $inc:
                        'counter.article': -1

                Model 'Theme', 'update', where, what, {multi: true}, (err) ->
                    cb err, doc
        ], cb

crud = new ArticleCrud
    modelName: 'Article'
    files: [
        {
            name: 'image.background'
            replace: true
            type: 'string'
        },
        {
            name: 'image.S'
            replace: true
            type: 'string'
        },
        {
            name: 'image.L'
            replace: true
            type: 'string'
        },
        {
            name: 'image.XL'
            replace: true
            type: 'string'
        },
        {
            name: 'desc.images'
            replace: false
            type: 'array'
        }
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud