_ = require 'lodash'
moment = require 'moment'
async = require 'async'

Model = require './mongooseTransport'

scoring = (client_id, rule, cb) ->
    async.waterfall [
        (next) ->
            Moneybox = Model 'Moneybox'
            doc = new Moneybox
                client_id: client_id
                rule_id: rule._id
                points: rule.points
                label: rule.label
            doc.save next
        (doc, affected, next) ->
            Model 'Client', 'findOne', { '_id': client_id }, next
        (doc, next) ->
            doc.points = if doc.points then doc.points + rule.points else rule.points
            doc.save next
    ], (err, user, num) ->
        cb err, user

isSingleCharged = (client_id, rule_id, cb) ->
    Model 'Moneybox', 'find', {
        client_id: client_id,
        rule_id: rule_id
    }, (err, docs) ->
        cb err, not docs.length

checkRestrictions = (client_id, rule, cb) ->
    return isSingleCharged client_id, rule._id, cb if not rule.multi

    async.each _.pairs(rule.limits.toObject()), (limit, proceed) ->
        return proceed() if limit[1] is 0

        Model 'Moneybox', 'count', {
            client_id: client_id
            rule_id: rule._id
            time:
                $gte: moment().startOf limit[0]
        }, (err, count) ->
            return proceed err if err
            proceed (if count < limit[1] then null else 'not allowed')
    , (err) ->
        allowed = true
        if err and err is 'not allowed'
            allowed = false
            err = null
        cb err, allowed

setPoints = (client_id, name, cb) ->
    rule = {}
    async.waterfall [
        (next) ->
            Model 'MoneyboxRule', 'findOne', { name: name }, next
        (doc, next) ->
            rule = doc
            checkRestrictions client_id, rule, next
        (allowed, next) ->
            return scoring client_id, rule, next if allowed
            next null, null
    ], cb

# Callback function takes two arguments err and user
api =
    registration: (client_id, cb) ->
        setPoints client_id, 'registration', cb
    profile: (client_id, cb) ->
        setPoints client_id, 'profile', cb
    login: (client_id, cb) ->
        setPoints client_id, 'login', cb
    like: (client_id, cb) ->
        setPoints client_id, 'like', cb
    comment: (client_id, cb) ->
        setPoints client_id, 'comment', cb
    invite: (client_id, cb) ->
        setPoints client_id, 'invite', cb
    septemberAction: (client_id, cb) ->
        setPoints client_id, 'septemberAction', cb

exports = api
module.exports = exports
