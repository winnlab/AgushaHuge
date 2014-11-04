async = require 'async'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

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
