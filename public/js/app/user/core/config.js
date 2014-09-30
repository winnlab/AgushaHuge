var config = {
	router: {
		base: '/',
		modulesContainer: '#modules',
		modules: [
			{
				name: 'main',
				path: {
					client: 'js/app/user/modules/main/',
					server: ''
				}
			}
		],
		defaultModule: 'main'
	}
};

export default config;