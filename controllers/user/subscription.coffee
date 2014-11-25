async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

tree = require '../../utils/tree'
breadcrumbs = require '../../meta/breadcrumbs'

exports.save = (req, res) ->
    data =
        client_id: req.user
        theme_id: req.body.theme_id

    DocModel = Model.apply Model, ['Subscription']
    doc = new DocModel data
    doc.save (err, doc) ->
        View.ajaxResponse res, err, doc

exports.remove = (req, res) ->
    async.waterfall [
        (next) ->
            if not req.user
                return next 'Ошибка. Неизвестный пользователь.'
            if not req.body.theme_id
                return next 'Ошибка. Неизвестная тема.'
            next null,
                client_id: req.user._id
                theme_id: req.body.theme_id
        (query, next) ->
            Model 'Subscription', 'findOne', query, next
        (doc, next) ->
            return doc.remove next if doc
            next 'Ошибка. Подписка не найдена.'
    ], (err, doc) ->
        View.ajaxResponse res, err, doc

exports.get = (req, res) ->
    data =
        breadcrumbs: tree.findWithParents breadcrumbs, 'subscriptions'
    async.waterfall [
        (next) ->
            return next 'Неизвестный пользователь' if not req?.user?._id
            Model 'Subscription', 'find', { client_id: req.user._id }, null, { lean: true }, next
        (docs, next) ->
            _.extend data, { 'subscriptions': docs }
            themes = Model 'Theme', 'find', { _id: { $in: _.pluck( docs, 'theme_id' ) } }, null
            themes.populate("age_id").exec next
        (docs, next) ->
            _.each data.subscriptions, (sub) ->
                _.each docs, (doc) ->
                    sub.name = doc.name if doc._id.toString() is sub.theme_id.toString()
                    sub.age = doc.age_id[0].title if doc._id.toString() is sub.theme_id.toString()
                    sub.ageImg = doc.age_id[0].icon.hover if doc._id.toString() is sub.theme_id.toString()
            next null
    ], (err) ->
        View.render 'user/subscriptions/index', res, data
