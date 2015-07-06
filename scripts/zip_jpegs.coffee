_ = require 'lodash'
async = require 'async'
path = require 'path'
fs = require 'fs'
gm = require('gm').subClass({ imageMagick: true })

imgPath = path.join process.cwd(), 'public', 'img', 'uploads'

async.waterfall [
  (next) ->
    fs.readdir imgPath, next
  (files, next) ->
    async.eachLimit files, 10, (file, next) ->
      parts = file.split('.')
      ext = parts[parts.length - 1].toLowerCase()

      if ext isnt 'jpg' and ext isnt 'jpeg'
        return do next

      gm(path.join(imgPath, file))
        .noProfile()
        .quality(75)
        .write(path.join(imgPath, file), (err) ->
          console.log "Ziped image #{file}..."
          next err
        )
    , next
], (err) ->
  if err
    console.log 'Error: '
    console.dir err
  else
    console.log 'Processing completed without errors! Exiting...'
    process.exit()
