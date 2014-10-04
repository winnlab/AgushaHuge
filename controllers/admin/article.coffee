Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Article'
    files: [
        {
            name: 'image'
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