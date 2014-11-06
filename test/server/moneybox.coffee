mongoose = require 'mongoose'

opts =
    server: { auto_reconnect: true, primary:null, poolSize: 50 },
    host: 'localhost'
    port: '27017'
    database: 'test'
    primary: null

connString = 'mongodb://'+opts.host+":"+opts.port+"/"+opts.database+"?auto_reconnect=true"

mongoose.connect connString, opts

mongoose.connection.on 'error', (err) ->
    console.log 'MongoDB connection error:', err

# Require models

Client = require '../../models/client'
MoneyboxModel = require '../../models/moneybox'
MoneyboxRuleModel = require '../../models/moneyboxRule'

async = require 'async'
should = require 'should'
Migrate = require '../../init/migrate'
Moneybox = require '../../lib/moneybox'
Model = require '../../lib/mongooseTransport'


clientId = '545728cc246da5ed0ed38908'

describe 'Moneybox', ->

    before (done) ->
        async.waterfall [
            (next) ->
                Migrate.init next
            (next) ->
                Model 'Client', 'findOne', _id: clientId, next
            (doc, next) ->
                unless doc
                    client =  new Client
                        _id: '545728cc246da5ed0ed38908'
                        points: 0
                    return client.save next
                next null
        ], done

    beforeEach (done) ->
        async.waterfall [
            (next) ->
                Model 'Moneybox', 'remove', { client_id: clientId }, next
            (docs, arg, next) ->
                Model 'Client', 'findOneAndUpdate', { _id: clientId }, { points: 0 }, next
        ], done

    checkPoins = (points, cb) ->
        Model 'Client', 'findOne', { _id: clientId }, (err, doc) ->
            doc.points.should.be.exactly points
            cb()

    it 'Should add points for single type task', (done) ->
        async.waterfall [
            (next) ->
                Moneybox.registration clientId, next
            (client, next) ->
                Moneybox.registration clientId, next
            (client, next) ->
                checkPoins 25, next
        ], done

    it 'Should add points for multiple task', (done) ->
        async.waterfall [
            (next) ->
                Moneybox.like clientId, next
            (client, next) ->
                Moneybox.like clientId, next
            (client, next) ->
                checkPoins 2, next
        ], done

    it 'Should add points for multiple task, with limitations', (done) ->
        async.waterfall [
            (next) ->
                Moneybox.comment clientId, next
            (client, next) ->
                Moneybox.comment clientId, next
            (client, next) ->
                Moneybox.comment clientId, next
            (client, next) ->
                Moneybox.comment clientId, next
            (client, next) ->
                checkPoins 3, next
        ], done
