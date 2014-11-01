Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Rank'
    files: [
            name: 'image'
            replace: true
            type: 'string'
        ,
            name: 'prize.$.image'
            nested: true
            replace: false
            type: 'array'
    ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud