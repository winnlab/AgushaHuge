async = require 'async'
moment = require 'moment'

View = require './view'
Model = require './model'
Logger = require './logger'
Mail = require './mail'
nodeExcel = require './excelExportFork'

# do we even need this file?

exports.sendMail = (template, options, callback) ->
  Mail.send template, options, callback

exports.exportDocs = (docs, callback) ->
  conf = {}

  conf.stylesXmlFile = "#{process.cwd()}/meta/styles.xml"

  conf.cols = [
    { caption: 'ID', type: 'number' },
    { caption: 'Логин', type: 'string' },
    { caption: 'E-m@il', type: 'string' },
    { caption: 'Баллы', type: 'number' },
    { caption: 'Дата регистрации', type: 'string' },
    { caption: 'Дата активации', type: 'string' },
    { caption: 'Тип', type: 'string' },
    { caption: 'Приглашение:', type: 'string' },
    { caption: 'Активен?', type: 'bool' },
    { caption: 'Подарок', type: 'bool' },
    { caption: 'Обработан?', type: 'bool' },
    { caption: 'Имя', type: 'string' },
    { caption: 'Телефон', type: 'string' },
    { caption: 'Город', type: 'string' },
    { caption: 'Улица', type: 'string' },
    { caption: 'Номер дома', type: 'string' },
    { caption: 'Квартира', type: 'string' },
    { caption: 'IP-адрес', type: 'string' }
  ]

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
    conf.rows.push [
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

  nodeExcel.executeAsync conf, 'STORE', (res) ->
    callback null, res
