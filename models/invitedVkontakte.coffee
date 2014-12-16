mongoose = require 'mongoose'

schema = new mongoose.Schema
    _id:
        type: String
        unique: true
,
    collection: 'invitedVkontante'
    _id: false

module.exports = mongoose.model 'InvitedVkontakte', schema