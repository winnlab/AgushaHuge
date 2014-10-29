Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'ProductAge'
    files: [
        {
            name: 'icon'
            replace: true
            type: 'string'
        },
        {
            name: 'hoverImage'
            replace: true
            type: 'string'
        },
        {
            name: 'desc_image'
            replace: true
            type: 'string'
        }
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud