moment = require 'moment'
mongoose = require 'mongoose'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
    client_id:
        type: ObjectId
        ref: 'Client'
        required: true
    theme_id:
        type: ObjectId
        ref: "Theme"
        set: mongoose.Types.ObjectId
        sparse: true
        required: true
    updated:
        type: Date
        required: true
        default: moment
,
    collection: 'subscription'

schema.pre 'save', (next) ->
    this.updated = moment()
    next()

module.exports = mongoose.model 'Subscription', schema
