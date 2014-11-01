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
            multiple: false
            _id: 'age_id'
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
            multiple: true
            path: 'age'
            property: 'fixture'
        ,
            model: 'Consultation'
            multiple: false
            path: 'age'
            property: 'fixture'
            _id: 'age_id'
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