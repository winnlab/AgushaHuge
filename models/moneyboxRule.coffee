mongoose = require 'mongoose'

schema = new mongoose.Schema
    name:
        type: String
        required: true
        unique: true
    label:
        type: String
        required: true
    description:
        type: String
        required: true
    points:
        type: Number
    active:
        type: Boolean
        default: true
    multi:
        type: Boolean
        default: true
    limits:
        day:
            type: Number
        week:
            type: Number
        month:
            type: Number
        year:
            type: Number
,
    collection: 'moneyboxRule'

module.exports = mongoose.model 'MoneyboxRule', schema
