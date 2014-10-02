should = require 'should'
_ = require 'lodash'

objUtils = require '../../utils/object.coffee'

describe 'object helper', ->
	describe 'searchHandle', ->
		console.time 'test'
		someObj = a: b: c: 42
		it 'should correctly search for 1 level nesting', ->
			objUtils.handleProperty(someObj, 'a').should.be.eql b: c: 42
		it 'should correctly search for 2 level nesting', ->
			objUtils.handleProperty(someObj, 'a.b').should.be.eql c: 42
		it 'should correctly search for 3 level nesting', ->
			objUtils.handleProperty(someObj, 'a.b.c').should.be.exactly 42
		it 'should return correct pointer to field', ->
			objUtils.handleProperty someObj, 'a.b.c', 99
			someObj.a.b.c.should.be.exactly 99
		it 'should correctly set string values', ->
			objUtils.handleProperty someObj, 'a.b.c', 'bla'
			someObj.a.b.c.should.be.exactly 'bla'
		it 'should return undefined if path passed incorrectly', ->
			res = objUtils.handleProperty someObj, 'a.c'
			(res is undefined).should.be.true
		it 'should do little performance test', ->
			someOtherObj = a: b: c: d: e: f: g: h: i: j: k: l: m: 42
			for i in [1...100]
				objUtils.handleProperty someOtherObj, 'a.b.c.d.e.f.g.h.i.j.k.l.m', 99
				someOtherObj.a.b.c.d.e.f.g.h.i.j.k.l.m.should.be.exactly 99
		console.timeEnd 'test'