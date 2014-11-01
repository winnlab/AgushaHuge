Crud = require '../../lib/crud'

crud = new Crud
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