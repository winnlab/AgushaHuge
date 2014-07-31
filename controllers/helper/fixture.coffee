mongoose = require 'mongoose'

exports.addConsultation = (req, res) ->
	doc = new mongoose.models.Consultation
	doc.name = 'Product' + Math.round Math.random() * 1000
	doc.text = 'Some random text bla bla bla bla'
	doc.type = req.params.id or 0
	doc.years = '53c93e7aa6fe8e316f622686'
	doc.theme = '53cfd938f9447f673d81171e'

	doc.save (err) ->
		res.send err or 'OK!'