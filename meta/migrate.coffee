mongoose = require 'mongoose'

module.exports = [
	modelName: 'permission'
	data: [
		_id: 'denied'
		name: 'access_denied'
	,
		_id: 'dashboard'
		name: 'dashboard'
	,
		_id: 'users'
		name: 'users'
	,
		_id: 'clients'
		name: 'clients'
	,
		_id: 'cache'
		name: 'cache'
	,
		_id: 'roles'
		name: 'roles'
	,
		_id: 'permisions'
		name: 'permissions'
	,
		_id: 'ranks'
		name: 'ranks'
	,
		_id: 'rank'
		name: 'rank'
	,
		_id: 'tmpUserRemove'
		name: 'tmpUserRemove'
	,
		_id: 'user'
		name: 'user'
	,
		_id: 'productCategory'
		name: 'productCategory'
	,
		_id: 'productCategories'
		name: 'productCategories'
	,
		_id: 'certificate'
		name: 'certificate'
	,
		_id: 'certificates'
		name: 'certificates'
	,
		_id: 'productAge'
		name: 'productAge'
	,
		_id: 'productAges'
		name: 'productAges'
	,
		_id: 'product'
		name: 'product'
	,
		_id: 'products'
		name: 'products'
	,
		_id: 'gallery'
		name: 'gallery'
	,
		_id: 'galleries'
		name: 'galleries'
	,
		_id: 'client'
		name: 'client'
	,
		_id: 'clients'
		name: 'clients'
	,
		_id: 'consultations'
		name: 'consultations'
	,
		_id: 'consultation'
		name: 'consultation'
	,
		_id: 'faq'
		name: 'faq'
	,
		_id: 'faqs'
		name: 'faqs'
	,
		_id: 'article'
		name: 'article'
	,
		_id: 'articles'
		name: 'articles'
	,
		_id: 'articleType'
		name: 'articleType'
	,
		_id: 'articleTypes'
		name: 'articleTypes'
	,
		_id: 'theme'
		name: 'theme'
	,
		_id: 'themes'
		name: 'themes'
	,
		_id: 'age'
		name: 'age'
	,
		_id: 'ages'
		name: 'ages'
	,
		_id: 'logout'
		name: 'logout'
	,
		_id: 'exportСlients'
		name: 'exportСlients'
	,
		_id: 'stats'
		name: 'stats'
	,
		_id: 'partner'
		name: 'partner'
	,
		_id: 'partners'
		name: 'partners'
	,
		_id: 'news'
		name: 'news'
	]
,
	modelName: 'role'
	data: [
		_id: 'admin'
		name: 'admin'
		permissions: [
			'denied'
			'dashboard'
			'users'
			'clients'
			'cache'
			'roles'
			'permisions'
			'ranks'
			'rank'
			'tmpUserRemove'
			'user'
			'productCategory'
			'productCategories'
			'certificate'
			'certificates'
			'productAge'
			'productAges'
			'product'
			'products'
			'gallery'
			'galleries'
			'client'
			'clients'
			'consultations'
			'consultation'
			'faq'
			'faqs'
			'article'
			'articles'
			'articleType'
			'articleTypes'
			'theme'
			'themes'
			'age'
			'ages'
			'logout'
			'exportСlients'
			'stats'
			'partner'
			'partners'
			'news'
		]
	,
		_id: 'user'
		name: 'user'
		permissions: []
	]
,
	modelName: 'user'
	data: [
		_id: '53b54577f5adc6a9932b1aec'
		username: 'admin'
		email: 'admin@admin.com'
		password: '79e262a81dd19d40ae008f74eb59edce'
		role: 'admin'
		status: 1
	]
,
	modelName: 'moneyboxRule'
	overwrite: true
	data: [
		_id: '545a2d0cf83d3cdf07cc7601'
		name: 'registration'
		label: 'Регистрация на сайте'
		description: 'единоразово'
		points: 25
		active: true
		multi: false
		limits:
			day: 0
			week: 0
			month: 0
			year: 0
	,
		_id: '545a2f32f83d3cdf07cc7602'
		name: 'profile'
		label: 'Заполнение профиля на 100%'
		description: 'единоразово'
		points: 30
		active: true
		multi: false
		limits:
			day: 0
			week: 0
			month: 0
			year: 0
	,
		_id: '545a2fe1f83d3cdf07cc7603'
		name: 'login'
		label: 'Регулярные заходы на сайт'
		description: '1 раз в неделю, с логином; максимум 4 балла в месяц'
		points: 1
		active: true
		multi: true
		limits:
			day: 0
			week: 1
			month: 4
			year: 0
	,
		_id: '545a306ff83d3cdf07cc7604'
		name: 'like'
		label: 'Оценка материала (внутренний лайк статьи)'
		description: '1 раз в неделю, с логином; максимум 4 балла в месяц'
		points: 1
		active: true
		multi: true
		limits:
			day: 10
			week: 0
			month: 100
			year: 0
	,
		_id: '545a31a1f83d3cdf07cc7605'
		name: 'comment'
		label: 'Комментарий к статье'
		description: 'максимум 3 балла в сутки, не более 30 баллов в месяц'
		points: 1
		active: true
		multi: true
		limits:
			day: 3
			week: 0
			month: 30
			year: 0
	,
		_id: '545a3222f83d3cdf07cc7606'
		name: 'invite'
		label: 'Приглашение друга на сайт (успешное)'
		description: 'не более 5 подруг в месяц'
		points: 5
		active: true
		multi: true
		limits:
			day: 0
			week: 0
			month: 5
			year: 0
	,
		_id: '5499b8b162a06a18d8b06150'
		name: 'septemberAction'
		label: 'Участие в акции "Первая тысяча"'
		description: 'Одноразовая акция'
		points: 100
		active: true
		multi: false
		limits:
			day: 0
			week: 0
			month: 0
			year: 0
	,
			_id: '549d5d756d32142da970870c'
			name: 'fbLike'
			label: 'Лайк, шеринг статьи в ФБ'
			description: '6 баллов в сутки; не более 60 баллов в месяц'
			points: 2
			active: true
			multi: true
			limits:
					day: 6
					week: 0
					month: 60
					year: 0
	,
		_id: '549d5d9c6d32142da970870d'
		name: 'vkLike'
		label: 'Лайк, шеринг статьи в ВК'
		description: '6 баллов в сутки; не более 60 баллов в месяц'
		points: 2
		active: true
		multi: true
		limits:
				day: 6
				week: 0
				month: 60
				year: 0
	,
			_id: '549d5db06d32142da970870e'
			name: 'okLike'
			label: 'Лайк, шеринг статьи в Одноклассниках'
			description: '6 баллов в сутки; не более 60 баллов в месяц'
			points: 2
			active: true
			multi: true
			limits:
					day: 6
					week: 0
					month: 60
					year: 0
		,
		_id: '549d5e196d32142da970870f',
		name: 'communityQuestion',
		label: 'Вопрос к сообществу',
		description: 'максимум 1 балл в сутки; не более 10 баллов в месяц',
		points: 1,
		active: true,
		multi: true,
		limits:
				day: 1,
				week: 0,
				month: 10,
				year: 0
	]
,
	modelName: 'client'
	keyField: 'email'
]
