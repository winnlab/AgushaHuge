Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Partner'
	
    files: [
        {
            name: 'image'
            replace: true
            type: 'string'
        }
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud