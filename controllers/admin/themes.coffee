Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Theme'

module.exports.rest = crud.request.bind crud