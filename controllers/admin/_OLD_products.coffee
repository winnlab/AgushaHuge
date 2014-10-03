async = require 'async'
_ = require 'underscore'
mongoose = require 'mongoose'

View = require '../../lib/view'
Model = require '../../lib/model'
Logger = require '../../lib/logger'

array = require '../../utils/array'

exports.index = (req, res) ->
	async.waterfall [
		(next) ->
			Model 'Product', 'find', next
		(docs, next) ->
			opts = 'age certificate category'

			Model 'Product', 'populate', next, docs, opts
		(docs) ->
			View.render 'admin/board/products/index', res, products: docs
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/products/index: %s #{err.message or err}"

preloadData = (product, cb) ->
	if typeof product is 'function'
		cb = product
		product = {}

	async.parallel
		categories: (next) ->
			Model 'Category', 'find', next, active: true
		ages: (next) ->
			Model 'Age', 'find', next, active: true
		certificates: (next)->
			Model 'Certificate', 'find', next
	, (err, results)->
		cb err if err

		results.product = product

		array.setPropertyByIntersection product.category, results.categories
		array.setPropertyByIntersection product.certificate, results.certificates

		if product.age
			for age in results.ages
				if age._id.toString() == product.age.toString()
					age.exists = true

		cb null, results

exports.get = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'Product', 'findOne', next, _id: _id
		preloadData
		(results) ->
			View.render 'admin/board/products/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/products/get: %s #{err.message or err}"

exports.create = (req, res) ->
	async.waterfall [
		preloadData
		(results) ->
			View.render 'admin/board/products/edit', res, results
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/products/create: %s #{err.message or err}"


exports.save = (req, res) ->
	_id = req.body.id

	data = req.body
	delete data._wysihtml5_mode if data._wysihtml5_mode

	data.image = req.files?.image?.name or ""

	if data['certificate[]']
		data.certificate = data['certificate[]']
		delete data['certificate[]']

	if data['category[]']
		data.category = data['category[]']
		if typeof data.category isnt 'object'
			data.category = [data.category]
		delete data['category[]']

	async.waterfall [
		(next) ->
			if _id
				async.waterfall [
					(next2) ->
						Model 'Product', 'findOne', next2, _id: _id
					(doc, next2) ->
						for own prop, val of data
							unless prop is 'id' or val is undefined
								doc[prop] = val

						doc.active = data.active or false

						doc.save next

				], (err) ->
					next err
			else
				Model 'Product', 'create', next, data

		(doc, affected, next) ->
			if typeof affected is 'function'
				next = affected

			if data.category
				async.waterfall [
					(next2) ->
						Model 'ProductPosition', 'find', next2, p_id: doc._id
					(cats, next2) ->
						catIdObjs = _.pluck cats, 'c_id'
						catsOld = _.map catIdObjs, (val) ->
							val.toString()

						catsToRemove = []
						catsToAdd = []

						for cat in data.category
							if catsOld.indexOf(cat) is -1
								catsToAdd.push cat

						for cat in catsOld
							if data.category.indexOf(cat) is -1
								catsToRemove.push cat

						async.parallel [
							(cb) ->
								iterator = (item, cb2) ->
									Model 'ProductPosition', 'remove', cb2, 
										p_id: doc._id
										c_id: item

								callback = (err) ->
									cb err

								async.each catsToRemove, iterator, callback

							(cb) ->
								iterator = (item, cb2) ->
									Model 'ProductPosition', 'create', cb2, 
										p_id: doc._id
										c_id: item
										position: 0

								callback = (err) ->
									cb err

								async.each catsToAdd, iterator, callback

						], (err, results) ->
							next err, doc
				], (err) ->
					next err
			else
				next null, doc

		(doc, next) ->
			unless doc
				return next "Произошла неизвестная ошибка."
			
			View.message true, 'Продукт успешно сохранен!', res

	], (err) ->
		Logger.log 'info', "Error in controllers/admin/products/save: #{err.message or err}", err
		msg = "Произошла ошибка при сохранении продукта: #{err.message or err}"
		View.message true, msg, res

exports.delete = (req, res) ->
	_id = req.params.id
	async.waterfall [
		(next) ->
			Model 'ProductPosition', 'remove', next, p_id: _id
		(affected, results, next) ->
			Model 'Product', 'remove', next, _id: _id
		() ->
			View.message true, 'Продукт успешно удален!', res
	], (err) ->
		Logger.log 'info', "Error in controllers/admin/products/remove: %s #{err.message or err}"
		msg = "Произошла ошибка при удалении продукта: #{err.message or err}"
		View.message false, msg, res

exports.saveMainPage = (req, res) ->
	ids = []
	for i in [1..3]
		ids.push {
			_id: req.body["main#{i}"]
			pos: i
		}

	iterator = (item, cb) ->
		async.waterfall [
			(next) ->
				Model 'Product', 'update', next, {}, {main_page: 0}
			(result, affected, next) ->
				Model 'Product', 'findOne', next, _id: item._id
			(doc, next) ->
				doc.main_page = item.pos
				doc.save cb

		], (err) ->
			cb err

	callback = (err) ->
		if err
			msg = "Произошла ошибка при сохранении главных продуктов: #{err.message or err}"
			success = false
		else
			msg = "Сохранение прошло успешно!"
			success = true

		View.message success, msg, res

	async.each ids, iterator, callback