Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Gallery'
    files: [
        {
            name: 'images'
            replace: false
            type: 'array'
        }
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud