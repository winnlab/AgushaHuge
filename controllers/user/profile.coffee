
router = require('express').Router()

Crud = require '../../lib/crud'
View = require '../../lib/view'
Model = require '../../lib/model'

router.use (req, res, next) ->
    if not req.user
        return next new Error 'User not exist'

    next()

router.get '/', (req, res, next) ->
	View.render 'user/profile/index',res, user: req.user

crud = new Crud
    modelName: 'Client'
    files: [
        name: 'image'
        replace: true
        type: 'string'
    ,
        name: 'child.image'
        replace: true
        type: 'string'
    ]

exports = {
	router: router
	rest: crud.request.bind crud
	restFile: crud.fileRequest.bind crud
}

module.exports = exports
