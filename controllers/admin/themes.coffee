async = require 'async'
router = require('express').Router()
_ = require 'lodash'

Crud = require '../../lib/crud'
Model = require '../../lib/mongooseTransport'
View = require '../../lib/view'

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
        
    query = [
        $group:
            _id: '$_id'
            position:
                $max: '$theme.position'
    ,
        $unwind: '$position'
    ,
        $group:
            _id: null
            maxPosition:
                $max: '$position'
    ,
        $project:
            _id: 0
            max: '$maxPosition'
    ]

    if id
        q0 =
            $match:
                'theme._id': id
        query = [q0].concat query

    async.parallel
        article: (cb) ->
            Model 'Article', 'aggregate', query, cb
        consultation: (cb) ->
            q0 =
                $match:
                    encyclopedia: true
            if id
                query[0] = _.extend query[0], q0
            else
                query = [q0].concat query

            Model 'Consultation', 'aggregate', query, cb
    , (err, results) ->
        aMax = results.article[0]?.max or 0
        cMax = results.consultation[0]?.max or 0
        max = Math.max aMax, cMax

        View.ajaxResponse res, err, max: max

router.get '/maxpos/:id?', getMaxPosition
router.get '/img', crud.fileRequest.bind crud
router.get '/:id?', crud.request.bind crud

module.exports = router