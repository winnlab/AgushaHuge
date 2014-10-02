async = require 'async'
_ = require 'lodash'

Crud = require '../../lib/crud'

crud = new Crud
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