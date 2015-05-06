async = require 'async'
moment = require 'moment'

ClientLib = require '../../lib/client'
Crud = require '../../lib/crud'
Model = require '../../lib/mongooseTransport'
Logger = require '../../lib/logger'
Client = require '../../lib/client'

class ClientCrud extends Crud
  _findAll: (req, cb) ->
    query = req.query
    fields = @_parseFields req.query
    options = @_parseOptions req.query

    page = query.page
    delete query.page

    limit = query.limit
    delete query.limit

    fn = if page and limit then 'findAllWithPagination' else 'findAll'
    @[fn].call this, query, cb, options, fields, page, limit

  findAllWithPagination: (query, cb, options, fields, page, limit) ->
    res =
      count: 0
      data: []

    if query.$or
      for item in query.$or
        for own prop of item
          item[prop] = new RegExp '.*' + item[prop] + '.*', 'g'
    ###
    `#Govnokod` ahead cause of mongoose issues #1950 (fixed in
    currently unstable 3.9.3) and #2374
    ###
    async.waterfall [
      (next) =>
        @DataEngine('find', null, query, fields, options)
          .sort(_id: -1)
          .exec next
      (docs) ->
        res.count = docs.length
        res.data = docs.slice (page - 1) * limit, page * limit

        cb null, res
    ], cb

    ###
    Left for future when mongoose sort and count functions
    will be compatible.
    ###
    # async.parallel
    #   count: (next) ->
    #     mongoQuery.count next
    #   data: (next) ->
    #     mongoQuery
    #      ###
    #        Should redo limit-skip into range-based find query.
    #        Something like:
    #        Model.find({_id: {$gt: `someId`}}).limit(limit).exec(next)
    #      ###
    #       .limit(limit)
    #       .skip((page - 1) * limit)
    #       .exec next
    # , cb

crud = new ClientCrud
  modelName: 'Client'
  files: [
      {
          name: 'image'
          replace: true
          type: 'string'
      }
  ]

module.exports.rest = crud.request.bind crud
module.exports.restFile = crud.fileRequest.bind crud

module.exports.export = (req, res) ->
  Client.processExport req, res

module.exports.downloadFile = (req, res) ->
  Client.downloadFile req, res
