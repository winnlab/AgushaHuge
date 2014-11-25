fs = require 'fs'
async = require 'async'

module.exports = (path, next) ->
	fs.readdir path, (err, files) ->
		throw err if err

		iterator = (file, cb) ->
			async.waterfall [
				(next) ->
					fs.stat path + file, next
				(stats) ->
					unless stats.isDirectory()
						require path + file
					
					cb()
			], next

		async.each files, iterator, next