_ = require 'lodash'
async = require 'async'
moment = require 'moment'

Model = require './mongooseTransport'

module.exports.childrenAges = (req, res) ->
  async.waterfall [
    (next) ->
      Model 'Client', 'find',
        children: $not: $size: 0
      , children: 1
      .lean true
      .exec next
    (docs) ->
      groups = []
      groups.push 0 for i in [0...12]

      now = do moment

      _.each docs, (client) ->
        _.each client.children, (child) ->
          b = child.birth
          stringAge = "#{b.year}.#{b.month}.#{b.day}"
          age = moment stringAge, 'YYYY.MM.DD'

          diff = now.diff age, 'months'

          if diff <= 3
            index = 0
          else if diff <= 5
            index = 1
          else if diff <= 7
            index = 2
          else if diff <= 9
            index = 3
          else if diff <= 11
            index = 4
          else if diff <= 17
            index = 5
          else if diff <= 18
            index = 6
          else if diff <= 24
            index = 7
          else if diff <= 30
            index = 8
          else if diff <= 35
            index = 9
          else if diff <= 48
            index = 10
          else
            index = 11

          groups[index] += 1

      res.send groups
  ], (err) ->
    if err
      res.status 500
      res.send err
