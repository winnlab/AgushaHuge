should = require 'should'

Database = require '../../init/database'

mongoose = require 'mongoose'
async = require 'async'
ModelPreload = require '../../init/mpload'
Model = require '../../lib/mongooseTransport.coffee'

ObjectId = mongoose.Schema.Types.ObjectId

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
			mdl = Model 'Test', (err, mdl) ->
				done err if err
				mdl.should.have.property 'modelName', 'Test'
				done()

	describe 'setting:', ->
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
			doc = new mdl
			doc.string = 'before'
			doc.save done

		it 'should update existing model', (done) ->
			cb = (err, affected) ->
				done err if err
				affected.should.be.exactly 1
				done()
			
			Model 'Test', 'update', string: "before", string: 'edited', cb


		it 'should remove existing model', (done) ->
			Model 'Test', 'remove', {}, (err) -> done err