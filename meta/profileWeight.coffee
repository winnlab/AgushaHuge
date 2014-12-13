
weights = 
	userInfo:
		fields: [
			'profile.first_name'
			'profile.last_name'
			'birth_date.year'
			'birth_date.month'
			'birth_date.day'
			'profile.gender'
		]
		weight: 30
	contactInfo:
		fields: [
			'contacts.country'
			'contacts.city'
			'contacts.street'
			'contacts.houseNum'
			'contacts.apartament'
		]
		weight: 25
	contactInfoLeft:
		fields: [
			'contacts.phone'
			'email',
			'email',
			'contacts.phone'
			'contacts.postIndex'
		]
		weight: 25
	photos:
		fields: [
			'image.large'
			'image.medium'
			'image.small'
		]
		weight: 20

exports = weights

module.exports = exports
