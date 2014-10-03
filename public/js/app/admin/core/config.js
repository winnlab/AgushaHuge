var config = {
	router: {
		base: '/admin/',
		modulesContainer: '#moduleContent',
		modules: [
			{
				name: 'dashboard',
				path: 'js/app/admin/modules/main/'
			},
			{
				name: 'encyclopedia/category',
				path: 'js/app/admin/modules/category/'
			},
			{
				name: 'encyclopedia/article',
				path: 'js/app/admin/modules/article/'
			},
			{
				name: 'encyclopedia/articleType',
				path: 'js/app/admin/modules/articleType/'
			}
		]
	}
};

export default config;