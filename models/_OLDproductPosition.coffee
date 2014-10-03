mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId
Mixed = mongoose.Schema.Types.Mixed

schema = new mongoose.Schema
	p_id:
		type: ObjectId
		ref: "Product"
		required: true
	c_id:
		type: ObjectId
		ref: "Category"
		required: true
	position:
		type: Number
		required: true
		default: 0
,
	collection: 'productPosition'



module.exports = mongoose.model 'ProductPosition', schema