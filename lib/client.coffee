fs = require 'fs'
path = require 'path'
request = require 'request'

Mail = require './mail'

exports.sendMail = (template, options, callback) ->
  Mail.send template, options, callback

exports.downloadFile = (req, res) ->
  fileName = "clients_#{req.body.token}.xlsx"
  filePath = path.join process.cwd(),
    '..', 'AgushaExcelExport', 'files', fileName

  res.setHeader 'Content-Type', 'application/vnd.openxmlformats'
  res.setHeader 'Content-Disposition',
    "attachment; filename=#{fileName}"
  res.sendFile filePath

exports.processExport = (req, res) ->
  if req.body.token
    makeRequest
      method: 'get'
      path: "getExport?token=#{req.body.token}"
      cb: (error, response, body) ->
        unless response
          res.status 500
          res.send 'Export server not responding...'
          return

        if error or response.statusCode isnt 200
          res.status response.statusCode or 500
          res.send error or response.statusMessage or 'Unknown Error'
          return


        res.status 200
        res.send 'OK'

  else
    makeRequest
      method: 'post'
      data: form: req.body
      path: 'export'
      cb: (error, response, body) ->
        if error or response.statusCode isnt 200
          res.status response.statusCode or 500
          res.send error or response.statusMessage or 'Unknown Error'
        else
          res.status 200
          res.send body

makeRequest = (params) ->
  request[params.method] "http://localhost:3579/#{params.path}",
    params.data or {}, params.cb
