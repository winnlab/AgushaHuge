Crud = require '../../lib/crud'

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

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud