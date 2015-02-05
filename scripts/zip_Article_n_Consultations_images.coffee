require '../init/database'

_ = require 'lodash'
async = require 'async'
mongoose = require 'mongoose'
path = require 'path'
gm = require('gm').subClass({ imageMagick: true })

Article = require '../models/article'

imgPath = path.join process.cwd(), 'public', 'img', 'uploads'
zipImgPath = path.join process.cwd(), 'public', 'img', 'uploads', 'zip'

processArticleImage = (article, next) ->
  images = []

  # async.eachSeries article.desc.images, (img, next) ->
  #   # parts = img.split('.')
  #   #
  #   # newName = if parts[1] === 'jpg' then img else "#{parts[0]}.jpg"
  #
  #   ext = img.split('.')[1]
  #
  #   if ['jpg', 'jpeg', 'png'].indexOf(img.toLowerCase()) is -1
  #     return do next
  #
  #   gm(path.join(imgPath, img))
  #     .quality(80)
  #     .write(path.join(imgPath, img), next)
  # , (err) ->
  #   return do next if err
  console.log "Processing article #{article._id}"
  async.eachSeries ['B', 'S', 'L', 'XL', 'SOCIAL'], (prop, next) ->
    unless _.isString article.image[prop]
      return do next

    img = article.image[prop]
    imgl = img.toLowerCase()

    parts = img.split('.')

    ext = parts[1]

    if ['jpg', 'jpeg', 'png'].indexOf(ext.toLowerCase()) is -1
      return do next

    gm(path.join(imgPath, img))
      .noProfile()
      .quality(80)
      .write(path.join(zipImgPath, parts[0] + '.jpg'), (err) ->
        console.log "Ziped image #{img}..."
        article.image[prop] = parts[0] + '.jpg'
        next err
      )
  , () ->
    article.save next

async.waterfall [
  (next) ->
    Article.find {}, next
  (articles, next) ->
    async.eachLimit articles, 5, processArticleImage, next
], (err) ->
  if err
    console.log 'Error: '
    console.dir err
  else
    console.log 'Processing completed without errors! Exiting...'
    process.exit()
