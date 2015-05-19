require '../init/database'

_ = require 'lodash'
async = require 'async'

Article = require '../models/article'
Consultation = require '../models/consultation'


async.waterfall [
  (next) ->
    Article.find {}, next
  (docs, next) ->
    async.each docs, (doc, done) ->
      doc.counter = {} unless doc.counter
      doc.counter.like = doc?.likes?.length or 0
      doc.counter.comment = doc?.commentaries?.length or 0
      answers = 0
      _.each doc.answer, (answer) ->
        answers += answer?.clients?.length or 0
      doc.counter.answer = answers
      doc.save done
    , next
  (next) ->
    Consultation.find {}, next
  (docs, next) ->
    async.each docs, (doc, done) ->
      doc.counter = {} unless doc.counter
      doc.counter.like = doc?.likes?.length or 0
      doc.counter.watch = doc?.watchers?.length or 0
      doc.save done
    , next
], (err) ->
  console.log err if err
  console.log 'done'
  process.exit()
