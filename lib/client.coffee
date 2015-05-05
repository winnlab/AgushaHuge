_ = require 'lodash'
async = require 'async'
moment = require 'moment'

View = require './view'
Model = require './mongooseTransport'
Logger = require './logger'
Mail = require './mail'
nodeExcel = require './excelExportFork'

exports.sendMail = (template, options, callback) ->
  Mail.send template, options, callback

aggregatePoints = (callback) ->
  Model 'Moneybox', 'aggregate', [
      $group:
        _id:
          client: '$client_id'
          month: $month: '$time'
          year: $year: '$time'
        points:
          $sum: '$points'
    ,
      $project:
        _id: false
        client_id: '$_id.client'
        month: '$_id.month'
        year: '$_id.year'
        points: true
    ]
  , callback

processDocuments = (docs, data, callback) ->
  conf = {}

  conf.stylesXmlFile = "#{process.cwd()}/meta/styles.xml"

  conf.cols = [
      caption: 'ID'
      type: 'number'
    ,
      caption: 'Логин'
      type: 'string'
    ,
      caption: 'E-m@il'
      type: 'string'
    ,
      caption: 'Баллы'
      type: 'number'
    ,
      caption: 'Дата регистрации'
      type: 'string'
    ,
      caption: 'Дата активации'
      type: 'string'
    ,
      caption: 'Тип'
      type: 'string'
    ,
      caption: 'Приглашение:'
      type: 'string'
    ,
      caption: 'Активен?'
      type: 'bool'
    ,
      caption: 'Подарок'
      type: 'bool'
    ,
      caption: 'Обработан?'
      type: 'bool'
    ,
      caption: 'Имя'
      type: 'string'
    ,
      caption: 'Телефон'
      type: 'string'
    ,
      caption: 'Город'
      type: 'string'
    ,
      caption: 'Улица'
      type: 'string'
    ,
      caption: 'Номер дома'
      type: 'string'
    ,
      caption: 'Квартира'
      type: 'string'
    ,
      caption: 'IP-адрес'
      type: 'string'
  ]

  date = do moment
  if date.isBefore [2014, 10, 1]
    return callback 'Incorrect date is set, could not calculate points ranges.'

  colDates = []
  until date.month() is 9 and date.year() is 2014
    conf.cols.push
      caption: date.format 'MMMM YYYY'
      type: 'number'

    colDates.push [do date.month, do date.year]
    date = date.subtract 1, 'months'

  conf.rows = []

  momentFormat = 'HH:mm:ss MM/DD/YYYY'

  for item, index in docs
    name = ''
    if item.profile?.last_name?.length
      name += item.profile.last_name + ' '
    if item.profile?.first_name?.length
      name += item.profile.first_name + ' '
    if item.profile?.middle_name?.length
      name += item.profile.middle_name

    created_at = moment(item.created_at).format 'YYYY.MM.DD HH:mm'
    activated_at = moment(item.activated_at).format 'YYYY.MM.DD HH:mm'
    rowData = [
      index
      item.login or ''
      item.email
      item.points
      created_at
      activated_at
      if item.type is 0 then 'Прямой' else 'Друг'
      item.invited_by?.login or 'N/A'
      item.active or 0
      item.status
      !item.newClient
      name
      item.contacts?.phone or 'N/A'
      item.contacts?.city or 'N/A'
      item.contacts?.street or 'N/A'
      item.contacts?.houseNum or 'N/A'
      item.contacts?.apartament or 'N/A'
      item.ip_address or 'N/A'
    ]

    for dates in colDates
      res = _.findWhere data,
        client_id: item._id
        month: dates[0] + 1
        year: dates[1] + 1

      rowData.push _.result res, 'points', 0

    conf.rows.push rowData

  nodeExcel.executeAsync conf, 'STORE', (res) ->
    callback null, res

exports.exportDocs = (docs, callback) ->
  aggregatePoints (data) ->
    processDocuments docs, data, callback
