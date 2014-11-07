async = require 'async'
router = require('express').Router()
_ = require 'lodash'

Crud = require '../../lib/crud'
Model = require '../../lib/mongooseTransport'
View = require '../../lib/view'
Logger = require '../../lib/logger'
getMaxFieldValue = require('../../lib/mongoHelpers').getMaxFieldValue

crud = new Crud
    modelName: 'Theme'
    denormalized: [
        property: 'name'
        denormalizedIn: [
            model: 'Article'
            path: 'theme'
            multiple: true
        ,
            model: 'Consultation'
            path: 'theme'
            multiple: true
        ]
    ]
    files: [
        {
            name: 'image'
            replace: true
            type: 'string'
        }
    ]

getMaxPosition = (req, res) ->
    id = req.params.id

    options = [
            model: 'Article'
            field: 'theme.position'
            findQuery:
                active: true
        ,
            model: 'Consultation'
            field: 'theme.position'
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

router.get '/maxpos/:id?', getMaxPosition
router.use '/img', crud.fileRequest.bind crud
router.use '/:id?', crud.request.bind crud

module.exports = router