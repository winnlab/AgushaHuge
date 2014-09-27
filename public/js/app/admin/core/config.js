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
				name: 'pages',
				path: 'js/app/admin/modules/pages'
			}
		]
	}
};

export default config;