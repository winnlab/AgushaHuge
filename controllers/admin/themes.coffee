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
            multiple: false
            _id: 'theme_id'
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