Crud = require '../../lib/crud'

crud = new Crud
    modelName: 'ArticleType'

module.exports.rest = crud.request.bind crud