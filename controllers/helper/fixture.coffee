mongoose = require 'mongoose'

exports.addConsultation = (req, res) ->
	doc = new mongoose.models.Consultation
	doc.name = 'Product' + Math.round Math.random() * 1000