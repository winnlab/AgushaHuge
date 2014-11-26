moment = require 'moment'
mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
    client_id:
        type: ObjectId
        ref: 'Client'
        required: true
    consultation_id:
        type: ObjectId
        ref: "Consultation"
        set: mongoose.Types.ObjectId
        sparse: true
        required: true
    updated:
        type: Date
        required: true
        default: moment
,
    collection: 'watchers'

schema.pre 'save', (next) ->
    this.updated = moment()
    next()

module.exports = mongoose.model 'Watcher', schema
