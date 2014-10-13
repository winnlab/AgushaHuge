mongoose = require 'mongoose'
sprintf = require('sprintf').sprintf

noModel = 'Exception in Model library: model with name %s does not exist'
noMethod = 'Exception in Model library: method with name %s does not exist'

module.exports = (modelName, methodName, args..., cb) ->
    if typeof methodName is 'function' and typeof cb isnt 'function'
        cb = methodName
        methodName = undefined

    mdl = mongoose.models[modelName]

    throw new Error sprintf noModel, modelName if mdl is undefined

    if methodName is undefined
        return if typeof cb is 'function' then cb null, mdl else mdl

    method = mdl[methodName]

    throw new Error sprintf noMethod, methodName if method is undefined

    args.push cb

    method.apply mdl, args