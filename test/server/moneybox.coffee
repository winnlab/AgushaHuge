Database = require '../../init/database'
ModelPreloader = require '../../init/mpload'

async = require 'async'
should = require 'should'
Moneybox = require '../../lib/moneybox'
Model = require '../../lib/mongooseTransport'


clientId = '545728cc246da5ed0ed38908'

describe 'Moneybox', ->

    before (done) ->
        ModelPreloader "#{process.cwd()}/models/", done

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
            (next) ->
                Moneybox.registration clientId, next
            (next) ->
                checkPoins 25, next
        ], done

    it 'Should add points for multiple task', (done) ->
        async.waterfall [
            (next) ->
                Moneybox.like clientId, next
            (next) ->
                Moneybox.like clientId, next
            (next) ->
                checkPoins 2, next
        ], done

    it 'Should add points for multiple task, with limitations', (done) ->
        async.waterfall [
            (next) ->
                Moneybox.comment clientId, next
            (next) ->
                Moneybox.comment clientId, next
            (next) ->
                Moneybox.comment clientId, next
            (next) ->
                Moneybox.comment clientId, next
            (next) ->
                checkPoins 3, next
        ], done
