Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'Consultation'

module.exports.rest = crud.request.bind crud