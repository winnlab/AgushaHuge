async = require 'async'
_ = require 'underscore'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'
mongoose = require 'mongoose'

exports.index = (req, res) ->
    years = []
    async.waterfall [
        (next) ->
            Model 'Years', 'find', {}, '-__v', next
        (docs, next) ->
            years = docs
            Model 'Theme', 'find', {}, '-__v', next
        (themes) ->
            View.render 'admin/board/encyclopedia/categories', res,
                years: years
                themes: themes
    ], (err) ->
        Logger.log 'info', "Error in #{module.filename}: #{err.message or err}"