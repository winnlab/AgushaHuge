
router = require('express').Router()

Crud = require '../../lib/crud'
View = require '../../lib/view'
Model = require '../../lib/model'

crud = new Crud
    modelName: 'Client'

router.use (req, res, next) ->
    if not req.user
        return res.redirect '/login'

    next()

router.get '/', (req, res, next) ->
    View.render 'user/profile/index',res, user: req.user

router.use '/crud/:id?', (req, res, next) ->
	if not req.params.id
		req.params.id = req.user.id

	crud.request.bind(crud) req, res, next


router.get '/logout', (req, res, next) ->
    req.logout()

    return res.redirect '/'

exports = {
	router: router
}

module.exports = exports
