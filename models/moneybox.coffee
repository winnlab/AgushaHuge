mongoose = require 'mongoose'
moment = require 'moment'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
    client_id:
        type: ObjectId
        ref: 'Client'
    rule_id:
        type: ObjectId
        ref: 'MoneyboxRule'
    time:
        type: Date
        required: true
        default: moment
    points:
        type: Number
        default: 0
    label:
        type: String
        default: ''
,
    collection: 'moneybox'

schema.pre 'save', (next) ->
    this.time = moment()
    next()

module.exports = mongoose.model 'Moneybox', schema
