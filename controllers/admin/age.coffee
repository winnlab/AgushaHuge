Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Age'

module.exports.rest = crud.request.bind crud