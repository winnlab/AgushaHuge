async = require 'async'
mongoose = require 'mongoose'
router = require('express').Router()
_ = require 'lodash'

Crud = require '../../lib/crud'
Image = require '../../lib/image'
Model = require '../../lib/mongooseTransport'
View = require '../../lib/view'
getMaxFieldValue = require('../../lib/mongoHelpers').getMaxFieldValue

objUtils = require '../../utils/object.coffee'
hprop = objUtils.handleProperty

class ArticleCrud extends Crud
    add: (data, cb) ->
        DocModel = @DataEngine()
        doc = new DocModel()

        for own field, value of data
            hprop doc, field, value

        async.waterfall [
            (next) =>
                @_checkThemePositions doc.theme, (err) ->
                    next err, doc
            (doc, next) ->
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
            cb err, unless err then doc else undefined

    _checkThemePositions: (theme, cb) ->
        async.map theme, (item, next) ->
            query =
                $and: [
                    'theme.position': item.position
                ,
                    'theme._id': item._id
                ]
            Model 'Article', 'find', query, (err, docs) ->
                return next err if err

                if docs.length > 1 or docs.length is 1 and not _.find(docs[0].theme, (doc) -> doc._id.toString() is item._id.toString())
                    next null, item.name
                else
                    next null, true

        , (err, results) ->
            msg = ''
            if results
                _.each results, (item) ->
                    if _.isString item
                        msg += "Позиция темы #{item} уже существует в рамках текущей темы (должна быть уникальной). "

            cb err or msg or null


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

                @_checkThemePositions doc.theme, (err) ->
                    next err, doc
            (doc, next) ->
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

    _crop: (req, cb) ->
        id = req.body.id or req.body._id
        data = req.body.data
        prefix = req.body.prefix

        _.forOwn data, (val, prop) -> data[prop] = parseInt val

        unless id and data and prefix
            return cb 'Ошибка. Не переданы все необходимые данные для вырезания изображения.'
        
        async.waterfall [
            (next) =>
                @findOne id, next
            (doc, next) =>
                unless doc.image.background
                    return next 'Ошибка. Изображение фона не задано или удалено.'

                if doc.image[prefix]
                    return @removeFile doc.image[prefix], (err) ->
                        next err, doc

                next null, doc
            (doc, next) ->
                Image.crop doc.image.background, prefix, data, (err) ->
                    next err, doc
            (doc, next) ->
                doc.image[prefix] = "cropped#{prefix}#{doc.image.background}"
                doc.image["data#{prefix}"] = data
                doc.save (err, doc) ->
                    next err, {
                        __v: doc.__v
                        filename: doc.image[prefix]
                        data: doc.image["data#{prefix}"]
                    }
        ], (err, data) ->
            cb err, data

    _removeCroppedFile: (req, cb) ->
        id = req.body.id or req.body._id
        prefix = req.body.prefix
        fileName = undefined

        async.waterfall [
            (next) ->
                unless id
                    err = 'Ошибка: неизвестно поле "id" файла.'
                
                next err
            (next) =>
                @DataEngine 'findById', next, id
            (doc, next) =>
                fileName = doc.image[prefix]
                unless typeof fileName is 'string'
                    return next 'Ошибка: попытка удалить неизвестный файл (скорее всего не передан префикс)'

                @removeFile fileName, (err) ->
                    next err, doc
            (doc, next) =>
                doc.image[prefix] = undefined

                doc.save next
            (doc, affected) ->
                data =
                    doc: doc
                    __v: doc.__v
                    name: fileName

                cb null, data

        ], cb

    cropRequest: (req, res) ->
        cb = (err, data) =>
            @result err, data, res

        switch req.method
            when "POST"
                @_crop req, cb
            when "DELETE"
                @_removeCroppedFile req, cb
            else
                cb 'Error: #{req.method} is not allowed!'

    remove: (id, cb) ->
        async.waterfall [
            (next) =>
                @DataEngine 'findById', next, id
            (doc, next) =>
                @_removeDocFiles doc, (err) ->
                    next err, doc
            (doc, next) ->
                imgs = ['S', 'L', 'XL']
                async.each imgs, (prefix, next) ->
                    if _.isString doc.image[prefix]
                        @removeFile doc.image[prefix], next
                    else
                        do next
                , (err) ->
                    next err, doc
            (doc) ->
                doc.remove cb
        ], cb

    findAll: (query, cb, options = {}, fields = null) ->
        # console.log 'opts', options
        if options.docsCount
            docsCount = options.docsCount
            delete options.docsCount
        else
            docsCount = 18

        if options.lastId
            # anchorId = mongoose.Types.ObjectId options.lastId
            anchorId = options.lastId
            delete options.lastId

        # console.log 'query', query
        # console.log docsCount, anchorId
        Model @options.modelName, 'findPaginated', query, fields, options, cb, docsCount, anchorId

crud = new ArticleCrud
    modelName: 'Article'
    files: [
        {
            name: 'image.background'
            replace: true
            type: 'string'
        },
        {
            name: 'desc.images'
            replace: false
            type: 'array'
        }
    ]

getMaxPosition = (req, res) ->
    id = req.params.id

    options = [
            model: 'Article'
            field: 'position'
            findQuery:
                active: true
        ,
            model: 'Consultation'
            field: 'position'
            findQuery:
                encyclopedia: true
                active: true
    ]

    if id
        options[0].findQuery['theme._id'] = id
        options[1].findQuery['theme._id'] = id

    getMaxFieldValue options, (err, max) ->
        Logger.log err if err
        View.ajaxResponse res, null, max: if _.isNumber max then max else 0

router.get '/maxpos', getMaxPosition
router.use '/img', crud.fileRequest.bind crud
router.use '/crop', crud.cropRequest.bind crud
router.use '/:id?', crud.request.bind crud

module.exports = router