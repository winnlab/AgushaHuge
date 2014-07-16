fs = require 'fs'
_ = require 'underscore'
async = require 'async'
sprintf = require 'sprintf'

Logger = require '../../lib/logger'

exports.get = (req, res) ->
	fs.readdir "./public/img/admin/attachable", (err, files) ->
		if err
			msg = "Error in wysi get: #{err.message or err}"
			Logger.log 'error', msg
			return res.send false

		results = []
		for f in files
			results.push {
				file: "/attachable/#{f}"
				caption: ""
			}

		res.send results


exports.upload = (req, res) ->
	image = req.files.file.name
	console.log req.files
	console.log image
	async.waterfall [
		(next) ->
			fs.rename "./public/img/#{image}", "./public/img/admin/attachable/#{image}", next
		() ->
			result =
				file: "/img/admin/attachable/#{image}"
				caption: ""
				status: 1

			res.send JSON.stringify result
	], (err) ->
			Logger.log 'error', "Error in wysi upload: #{err.message or err}"
			res.send '{}'