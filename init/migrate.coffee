_ = require 'lodash'
async = require 'async'

metaMigrate = require '../meta/migrate'

checkMigration = (migrate, callback) ->
	Model = require '../models/' + migrate.modelName
	
	async.waterfall [
		(next) ->
			Model.count next
		(count) ->
			# if count > 0
				# return callback null
			
			if not migrate.data?
				migrate.data = require '../meta/' + migrate.modelName
			
			if migrate.overwrite is false
				Model.create migrate.data, -> do callback
			else
				async.each migrate.data, (data, next) ->
					options = {}
					
					keyField = '_id'
					
					if migrate.keyField
						keyField = migrate.keyField
					
					options[keyField] = data[keyField]
					
					Model.findOne options, (err, doc) ->
						# if doc
							# return next null
						
						Model.findOneAndUpdate options, data, upsert: true, next
				, callback
	] , callback

exports.init = (callback)->
    async.eachSeries metaMigrate, checkMigration, callback