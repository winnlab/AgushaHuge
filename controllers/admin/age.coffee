Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Age'
    denormalized: [
        property: 'title'
        denormalizedIn: [
            model: 'Article'
            path: 'age'
            multiple: true
        ,
            model: 'Consultation'
            path: 'age'
            multiple: true
        ]
    ]
    files: [
        name: 'icon.normal'
        replace: true
        type: 'string'
    ,
        name: 'icon.hover'
        replace: true
        type: 'string'
    ,
        name: 'icon.fixture'
        replace: true
        type: 'string'
        denormalizedIn: [
            model: 'Article'
            path: 'age'
            property: 'fixture'
            multiple: true
        ,
            model: 'Consultation'
            path: 'age'
            property: 'fixture'
            multiple: true
        ]
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