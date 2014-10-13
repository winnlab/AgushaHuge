should = require 'should'
_ = require 'lodash'

objUtils = require '../../utils/object.coffee'

describe 'object helper', ->
	describe 'handleProperty', ->
		console.time 'test'
		someObj = a: b: c: 42
		it 'should correctly search for 1 level nesting', ->
			objUtils.handleProperty(someObj, 'a').should.be.eql b: c: 42
		it 'should correctly search for 2 level nesting', ->
			objUtils.handleProperty(someObj, 'a.b').should.be.eql c: 42
		it 'should correctly search for 3 level nesting', ->
			objUtils.handleProperty(someObj, 'a.b.c').should.be.exactly 42
		it 'should correctly set value', ->
			objUtils.handleProperty someObj, 'a.b.c', 99
			someObj.a.b.c.should.be.exactly 99
		it 'should correctly set string value', ->
			objUtils.handleProperty someObj, 'a.b.c', 'bla'
			someObj.a.b.c.should.be.exactly 'bla'
		it 'should return undefined if path passed incorrectly and no value provided and shouldnt create nested', ->
			res = objUtils.handleProperty someObj, 'a.c.d'
			(res is undefined).should.be.true
			someObj.a.c.should.be.undefined
		it 'should do little performance test', ->
			someOtherObj = a: b: c: d: e: f: g: h: i: j: k: l: m: 42
			for i in [1...100]
				objUtils.handleProperty someOtherObj, 'a.b.c.d.e.f.g.h.i.j.k.l.m', 99
				someOtherObj.a.b.c.d.e.f.g.h.i.j.k.l.m.should.be.exactly 99
		it 'should create property if not exist', ->
			someAnotherObj = a: {}
			objUtils.handleProperty someAnotherObj, 'a.b', 55
			someAnotherObj.a.b.should.be.exactly 55
		it 'should create nested property if not exist', ->
			someAnotherObj = a: {}
			objUtils.handleProperty someAnotherObj, 'a.b.d', 66
			someAnotherObj.a.b.d.should.be.exactly 66
		console.timeEnd 'test'