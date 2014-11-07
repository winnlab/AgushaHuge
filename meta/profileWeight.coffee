
weights = 
	userInfo:
		fields: [
			'profile.first_name'
			'profile.last_name'
			'profile.birth_date.year'
			'profile.birth_date.month'
			'profile.birth_date.day'
			'profile.gender'
			'profile.about'
		]
		weight: 30
	contactInfo:
		fields: [
			'contacts.country'
			'contacts.city'
			'contacts.street'
			'contacts.houseNum'
			'contacts.apartament'
			'contacts.phone'
			'contacts.email'
			'contacts.spareEmail'
		]
		weight: 30
	social:
		fields: [
			'social.fb.id'
			'social.vk.id'
			'social.ok.id'
		],
		weight: 40

exports = weights

module.exports = exports
