Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'FAQ'

module.exports.rest = crud.request.bind crud