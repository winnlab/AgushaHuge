should = require 'should'

Database = require '../init/database'

mongoose = require 'mongoose'
async = require 'async'
ModelPreload = require '../init/mpload'
Model = require '../lib/model.coffee'

describe 'ModelPreload', ->
	it 'should preload test model', (done) ->
		ModelPreload "#{process.cwd()}/models/", ->
			mongoose.models.Test.should.have.property 'modelName', 'Test'
			done()

describe 'Model', ->
	describe 'getting', ->
		it 'should return a model instance if no method provided, and do it synchronously if no cb provided', ->
			mdl = Model 'Test'
			mdl.should.have.property 'modelName', 'Test'
		it 'should return a model instance if no method provided, and do it asynchronously if cb provided', (done) ->
			mdl = Model 'Test', null, (err, mdl) ->
				done err if err
				mdl.should.have.property 'modelName', 'Test'
				done()

	describe 'saving', ->
		it 'should create new document in collection', (done) ->
			mdl = Model 'Test'
			doc = new mdl
			
			doc.string = 'test'
			doc.number = 42
			doc.date = Date.now()
			doc.bool = true

			doc.save (err, doc, affected) ->
				done err if err

				affected.should.be.exactly 1

				doc.should.have.property '_id'
				doc._id.should.not.be.empty

				done()

		before (done) ->
			mdl = Model 'Test'
			async.parallel [
				(cb) ->
					doc1 = new mdl
					doc1._id = "53f4db0528ee770512d71354"
					doc1.string = 'before'
					doc1.save cb
				(cb) ->
					doc2 = new mdl
					doc2._id = "53f4db0528ee770512d71355"
					doc2.string = 'toRemove'
					doc2.save cb
			], ->
				done()

		it 'should update existing model', (done) ->
			cb = (err, doc) ->
				done err if err

				doc.should.have.property 'string', 'before'
				doc.string = 'edited'
				doc.save (err, doc, affected) ->
					done err if err

					affected.should.be.exactly 1
					doc.should.have.property 'string', 'edited'

					done()
			
			Model 'Test', 'findOne', cb, _id: "53f4db0528ee770512d71354"


		it 'should remove existing model', (done) ->
			Model 'Test', 'findOne', cb, _id: "53f4db0528ee770512d71355"
			cb = (err, doc) ->
				done err if err

				(err == null).should.be.true
				doc.remove (err, doc) ->
					done err if err

					doc.should.have.property '_id', "53f4db0528ee770512d71355"
					done()

			undefined

		after (done) ->
			Model 'Test','remove', done, _id: "53f4db0528ee770512d71354"