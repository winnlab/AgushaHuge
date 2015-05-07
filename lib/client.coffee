fs = require 'fs'
path = require 'path'
request = require 'request'
_ = require 'lodash'

Mail = require './mail'

exportedFilesPath = path.join process.cwd(), '..', 'AgushaExcelExport', 'files'
exportedFilesDir = (fileName) ->
  unless _.isString(fileName) and fileName.length > 0
    return exportedFilesPath

  path.join exportedFilesPath, fileName

exports.sendMail = (template, options, callback) ->
  Mail.send template, options, callback

getNewestFile = (files, callback) ->
  return unless typeof callback is 'function'

  if not files or files.length is 0
    return do callback 'На сервере нет файлов экспорта.'

  if files.length is 1
    if files[0] is '.gitignore'
      return callback 'На сервере нет файлов экспорта.'
    else
      return callback null, files[0]

  newest = file: files[0]
  checked = 0
  fs.stat exportedFilesDir(newest.file), (err, stats) ->
    newest.mtime = stats.mtime
    for i in [0..files.length]
      file = files[i]
      ((file) ->
        fs.stat exportedFilesDir(file), (err, stats) ->
          ++checked

          return if err

          if do stats.mtime.getTime > do newest.mtime.getTime
            newest =
              file: file
              mtime: stats.mtime

          if checked is files.length
            callback null, newest.file
      ) file

getFileName = (token, callback) ->
  unless token is 'last'
    return callback null, "clients_#{token}.xlsx"

  fs.readdir exportedFilesPath, (err, files) ->
    return callback err if err
    getNewestFile files, callback

exports.downloadFile = (req, res) ->
  getFileName req.body.token, (err, fileName) ->
    res.setHeader 'Content-Type', 'application/vnd.openxmlformats'
    res.setHeader 'Content-Disposition',
      "attachment; filename=#{fileName}"
    res.sendFile exportedFilesDir fileName

exports.processExport = (req, res) ->
  if req.body.token
    makeRequest
      method: 'get'
      path: "getExport?token=#{req.body.token}"
      cb: (error, response, body) ->
        return res.sendStatus 503 unless response

        if error or response.statusCode isnt 200
          res.status response.statusCode or 500
          res.send error or response.statusMessage or 'Unknown Error'
          return

        res.sendStatus 200

  else
    makeRequest
      method: 'post'
      data: form: req.body
      path: 'export'
      cb: (error, response, body) ->
        return res.sendStatus 503 unless response

        if error or response.statusCode isnt 200
          res.status response.statusCode or 500
          res.send error or response.statusMessage or 'Unknown Error'
        else
          res.status 200
          res.send body

makeRequest = (params) ->
  request[params.method] "http://localhost:3579/#{params.path}",
    params.data or {}, params.cb
