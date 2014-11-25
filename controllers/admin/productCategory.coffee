Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'ProductCategory'

module.exports.rest = crud.request.bind crud