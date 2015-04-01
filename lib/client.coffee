async = require 'async'

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
		conf.rows.push [
			index,
			item.login,
			item.email,
			item.created_at or 'N/A',
			item.activated_at or 'N/A',
			item.type,
			item.invited_by?.login or 'N/A',
			item.active or 0,
			item.status,
			!item.newClient,
			("#{item.lastName} #{item.firstName} #{item.patronymic}") or 'N/A',
			item.phone or 'N/A',
			item.city?.name or 'N/A',
			item.street or 'N/A',
			item.house or 'N/A',
			item.apartment or 'N/A',
			item.ip_address or 'N/A'
		]

	nodeExcel.executeAsync conf, 'STORE', (res) ->
		callback null, res
