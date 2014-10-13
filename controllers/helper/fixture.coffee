mongoose = require 'mongoose'
moment = require 'moment'
async = require 'async'

Model = require '../../lib/model'

exports.addConsultation = (req, res) ->
	doc = new mongoose.models.Consultation
	doc.name = 'Product' + Math.round Math.random() * 1000
	doc.text = 'Some random text bla bla bla bla'
	doc.type = req.params.id or 0
	doc.years = '53c93e7aa6fe8e316f622686'
	doc.theme = '53cfd938f9447f673d81171e'

	doc.save (err) ->
		res.send err or 'OK!'

exports.addAnswer = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Client', 'find', next
		(docs, next) ->
			doc = new mongoose.models.Answer
			doc.date = moment()
			doc.text = 'BLABAL <br/> BLA!'
			doc.author = docs[0]?._id or null

			doc.save next
		(doc) ->
			res.send doc._id or 'Something went wrong :('
	], (err) ->
		res.send err

exports.linkCosultationAnswer = (req, res) ->
	c_id = req.params.c
	a_id = req.params.a

	async.waterfall [
		(next) ->
			Model 'Consultation', 'findOne', next, _id: c_id
		(doc, next) ->
			doc.answer.push a_id
			doc.save next
		(doc) ->
			res.send 'OK!'
	], (err) ->
		res.send err