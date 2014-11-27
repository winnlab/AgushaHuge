async = require 'async'
_ = require 'lodash'

View = require '../../lib/view'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'

exports.toggleWatch = (req, res) ->
    _id = req.body._id
    userId = req?.user?._id
    toggleResult = null
    consultation = null

    unless _id and userId
        Logger.log 'info', "Error in controllers/user/watch/toggleWatch: Not all of the variables were received"
        return res.send "Error in controllers/user/watch/toggleWatch: Not all of the variables were received"

    async.waterfall [
        (next) ->
            Model 'Consultation', 'findOne', _id: _id, next
        (doc, next) ->
            if doc
                if doc.watchers
                    likeIndex = _.findIndex doc.watchers, (element) ->
                        return element.toString() is userId.toString()

                    if likeIndex isnt -1
                        doc.watchers.splice likeIndex, 1
                        toggleResult = 0
                    else
                        doc.watchers.push userId
                        toggleResult = 1
                else
                    doc.watchers.push userId
                    toggleResult = 1
                doc.save next
            else
                next "Error in controllers/user/watch/toggleWatch: No document was found in Consultation model with _id: #{_id}"
        (doc, affected , next) ->
            consultation = doc
            if toggleResult
                Watcher = Model 'Watcher'
                watch = new Watcher
                    client_id: userId
                    consultation_id: _id
                watch.save next
            else
                Model 'Watcher', 'remove', { client_id: userId, consultation_id: _id }, next
        () ->
            View.ajaxResponse res, null, {doc: consultation, toggleResult: toggleResult}

    ], (err) ->
        error = err.message or err
        Logger.log 'info', "Error in controllers/user/watch/toggleWatch: #{error}"
        res.send error
