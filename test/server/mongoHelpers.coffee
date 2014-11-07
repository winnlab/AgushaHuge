###
    Run with next command:
        mocha --compilers coffee:coffee-script/register test/server/mongoHelpers.coffee
###

async = require 'async'
mongoose = require 'mongoose'
should = require 'should'

mongoHelpers = require '../../lib/mongoHelpers'
getMaxFieldValue = mongoHelpers.getMaxFieldValue

modelDirPath = '../../models/'
Article = require "#{modelDirPath}article"
Consultation = require "#{modelDirPath}consultation"

clearDatabase = (done) ->
    async.parallel [
        (next) ->
            Article.remove {}, next
        (next) ->
            Consultation.remove {}, next
    ], done

describe 'mongoHelpers', ->

    describe '.getMaxFieldValue', ->
        before (done) ->
            opts =
                server: auto_reconnect: true, primary: null, poolSize: 50
                user: ''
                pass: ''
                host: 'localhost'
                port: '27017'
                database: 'TestHelpers'
                primary: null

            connString = 'mongodb://'+opts.user+":"+opts.pass+"@"+opts.host+":"+opts.port+"/"+opts.database+"?auto_reconnect=true"

            mongoose.connect connString, opts

            mongoose.connection.on 'error', (err) ->
                console.log 'MongoDB connection error:', err
                process.exit()

            mongoose.connection.on 'connected', () ->
                clearDatabase () ->

                    articles = [
                            type:
                                name: 'typename'
                            title: 'article1'
                            active: true
                            recommended: false
                            position: 29
                            age: [
                                { _id: mongoose.Types.ObjectId "545b7f72b33f4ef72c5ab6a0" }
                            ]
                            theme: [
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a1"
                                    position: 5
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a2"
                                    position: 10
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a3"
                                    position: 15
                            ]
                        ,
                            type:
                                name: 'typename'
                            title: 'article2'
                            active: true
                            recommended: false
                            position: 15
                            age: [
                                { _id: mongoose.Types.ObjectId "545b7ffab33f4ef72c5ab6a2" }
                            ]
                            theme: [
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a1"
                                    position: 50
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a2"
                                    position: 25
                            ]
                    ]

                    consultations = [
                            type:
                                name: 'typename'
                            name: 'cons1'
                            text: 'blablabla'
                            active: true
                            encyclopedia: true
                            position: 25
                            age: [
                                { _id: mongoose.Types.ObjectId "545b7f72b33f4ef72c5ab6a0" }
                            ]
                            theme: [
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a1"
                                    position: 1
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a2"
                                    position: 51
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a3"
                                    position: 9
                            ]
                        ,
                            type:
                                name: 'typename'
                            name: 'cons2'
                            text: 'blablabla'
                            active: true
                            encyclopedia: false
                            position: 30
                            age: [
                                { _id: mongoose.Types.ObjectId "545b7f72b33f4ef72c5ab6a0" }
                            ]
                            theme: [
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a1"
                                    position: 999
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a2"
                                    position: 9999
                                ,
                                    _id: mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a3"
                                    position: 999
                            ]
                    ]

                    async.parallel
                        a: (next) ->
                            async.each articles, (a, next) ->
                                item = new Article a
                                item.save next
                            , next
                        b: (next) ->
                            async.each consultations, (c, next) ->
                                item = new Consultation c
                                item.save next
                            , next
                    , done

        it 'Should find total maximum from all received options', (done) ->
            # # Article.find {}, {position: 1}, (err, docs) ->
            # Article.count {}, (err, docs) ->
            #     console.log "ARTICLE DOCS", docs
            #     return do done
            # return
            options = [
                    model: 'Article'
                    field: 'position'
                    findQuery:
                        active: true
                ,
                    model: 'Consultation'
                    field: 'position'
                    findQuery:
                        active: true
                        encyclopedia: true
            ]

            getMaxFieldValue options, (err, max) ->
                (max).should.be.exactly 29
                do done

        it 'Should find total maximum using nested property', (done) ->
            options = [
                    model: 'Article'
                    field: 'theme.position'
                ,
                    model: 'Consultation'
                    field: 'theme.position'
            ]

            getMaxFieldValue options, (err, max) ->
                (max).should.be.exactly 9999
                done()

        it 'Should take findQuery options into account', (done) ->
            options = [
                    model: 'Article'
                    field: 'theme.position'
                    findQuery:
                        active: true
                ,
                    model: 'Consultation'
                    field: 'theme.position'
                    findQuery:
                        active: true
                        encyclopedia: true
            ]

            getMaxFieldValue options, (err, max) ->
                (max).should.be.exactly 51
                done()

        it 'Should correctly work with nested properties in findQuery', (done) ->
            options = [
                    model: 'Article'
                    field: 'theme.position'
                    findQuery:
                        active: true
                        'theme._id': mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a1"
                ,
                    model: 'Consultation'
                    field: 'theme.position'
                    findQuery:
                        active: true
                        encyclopedia: true
                        'theme._id': mongoose.Types.ObjectId "545b7fa1b33f4ef72c5ab6a1"
            ]

            getMaxFieldValue options, (err, max) ->
                (max).should.be.exactly 51
                done()

        after (done) ->
            clearDatabase done