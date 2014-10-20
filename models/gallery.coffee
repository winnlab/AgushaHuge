mongoose = require 'mongoose'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
	name:
		type: String
		required: true
	images:
		type: Array
    article:
        type: ObjectId
        ref: "Article"
,
	collection: 'gallery'

module.exports = mongoose.model 'Gallery', schema