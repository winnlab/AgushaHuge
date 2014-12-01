
path = require 'path'
join = path.join
fs = require 'fs'
path = require 'path'
md5 = require 'MD5'
request = require 'request'
config = require '../../config.json'

_ = require 'lodash'
gm = require('gm').subClass imageMagick: true
async = require 'async'

router = require('express').Router()

Crud = require '../../lib/crud'
View = require '../../lib/view'
Model = require '../../lib/model'
Cities = require '../../meta/cities'

urlPrefix = 
    child: "/img/uploads/child"
    profile: "/img/uploads/profile"

pathToProfileImages = join.apply path, [
    __dirname
    '../..'
    'public/img/uploads/profile'
]

pathToChildProfile = join.apply path, [
    __dirname
    '../..'
    'public/img/uploads/child'
]

sizes =
    profile:
        paths:
            orig: join.apply path, [pathToProfileImages, 'orig']
            large: join.apply path, [pathToProfileImages, 'large']
            medium: join.apply path, [pathToProfileImages, 'medium']
            small: join.apply path, [pathToProfileImages, 'small']
        sizes:
            large: 120
            medium: 100
            small: 50
    child:
        paths:
            orig: join.apply path, [pathToChildProfile, 'orig']
            large:  join.apply path, [pathToChildProfile, 'large']
            small: join.apply path, [pathToChildProfile, 'small']
        sizes:
            large: 100
            small: 50

fileKey =
    profile:
        name: 'profile'
        prop: 'image'
    child:
        name: 'child'
        prop: 'image'

crud = new Crud
    modelName: 'Client'

isCropImage = (params) ->
    keys = ['x', 'y', 'width', 'height']

    _.every keys, (key) ->
        return params[key]

remove = (imageName, type, callback) ->
    console.log imageName
    pathsToImage = {}

    _.each sizes[type].paths, (path, key, list) ->
        pathsToImage[key] = join path, imageName

    async.each Object.keys(pathsToImage), (key, next)->
        fs.unlink pathsToImage[key], next
    , callback

resize = (src, dest, width, height, next) ->
    gm(src)
        .thumb width, height, dest, 80, (err) ->
            next err, dest

crop = (name, type, params, next) ->
    srcDir = path.dirname params.paths['orig']
    srcPath = join srcDir, name
    srcDest = join params.paths['orig'], name

    gm(srcPath)
        .crop(
            params.width, 
            params.height, 
            params.x, 
            params.y
        )
        .write srcDest, (err)->
            return next err if err

            next null, srcDest

resizeImage = () ->
    (req, res, next) ->
        name = res.locals.resize.name
        type = res.locals.resize.type
        resizes = sizes[type].sizes
        src = res.locals.resize.path

        srcDir = path.dirname path.dirname res.locals.resize.path

        async.map Object.keys(resizes), (k, cb) ->
            width = resizes[k]
            height = resizes[k]

            dest = join srcDir, k, name
            
            resize src, dest, width, height, cb
        , (err, destinations) ->
            res.locals.images = {}

            _.each Object.keys(resizes), (value, key, list) ->
                res.locals.images[value] = join urlPrefix[type], value, name

            next()

cropImage = () ->
    (req, res, next) ->
        return next() unless isCropImage req.query

        key = _.find fileKey, (item, key, list) ->
            return false unless req.files[key]

            return true

        file = req.files[key.name]

        params = _.extend req.query, sizes[key.name]

        crop file.name, key.name, params, (err, orig)->
            return next err if err
            
            res.locals.resize =
                name: file.name
                path: orig
                type: key.name

            next()

removeImage = () ->
    (req, res, next) ->
        image = req.query.name
        type = req.query.type

        remove image, type, (err) ->
            return next err if err

            next()

resizeResponse = () ->
    (req, res, next) ->
        res.locals.is_ajax_request = true

        View.render null, res

removeResponse = () ->
    (req, res, next) ->
        res.locals.is_ajax_request = true

        View.render null, res

getCities = () ->
    (req, res, next) ->
        filtered = _.filter Cities, (item, key, list) ->
            item.name.match new RegExp req.body.term.trim(), 'i'

        _.each filtered, (item, key, list) ->
            list[key] =
                id: item.name
                text: item.name

        res.locals.cities = filtered
        next()

renderCities = ()->
    (req, res, next) ->
        res.json res.locals.cities

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

router.get '/checkAuth', (req, res) ->
    expire = req.param 'expire'
    mid = req.param 'mid'
    sid = req.param 'sid'
    secret = req.param 'secret'
    
    sig = req.param 'sig'

    check = _.every [expire, mid, sid, secret], (item) ->
        return _.isString(item) or _.isNumber(item)

    unless check
        return res.send false

    sign = md5 "expire=#{expire}mid=#{mid}secret=#{secret}sid=#{sid}#{config.vk.CLIENT_SECRET}"

    if sign is sig and expire > Math.floor Date.now() / 1000
        return res.send true

    res.status 418
    res.send false

router.post '/uploadVK', (req, res) ->
    uploadUrl = req.param 'uploadUrl'

    async.waterfall [
        (next) ->
            r = request.post uploadUrl, next
            form = r.form()

            pathToImage = path.join process.cwd(), 'public', 'img', 'no_photo.png'
            form.append 'photo', fs.createReadStream(pathToImage), {contentType: 'image/png', filename: 'no_photo.png'}
        (response, body) ->
            res.send body
    ], (err) ->
        res.status 500
        res.send err

router.get '/invitedVK', (req, res) ->
    Model 'InvitedVkontakte', 'findOne', fn, _id: req.param 'uid'

    fn = (err, doc) ->
        if err
            res.status 500
            return res.send err

        res.send doc and true or false

router.post '/invitedVK', (req, res) ->
    _id = req.param 'uid'

    mdl = new Model('InvitedVkontakte'),
        _id: _id

    mdl.save (err) ->
        res.send not err

router.post.apply router, [
    '/cities',
    getCities()
    renderCities()
]

router.post.apply router, [
    '/upload'
    cropImage()
    resizeImage()
    resizeResponse()
]

router.delete.apply router, [
    '/upload'
    removeImage()
    removeResponse()
]

exports = {
	router: router
}

module.exports = exports
