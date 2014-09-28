var config = {
	router: {
		base: '/admin/',
		modulesContainer: '#moduleContent',
		modules: [
			{
				name: 'dashboard',
				path: 'js/app/admin/modules/main'
			},
			{
				name: 'encyclopedia-category',
				path: 'js/app/admin/modules/category'
			}
		]
	}
};

export default config;