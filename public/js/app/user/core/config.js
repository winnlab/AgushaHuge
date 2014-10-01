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
			},
			{
				name: 'registration',
				path: {
					client: 'js/app/user/modules/registration/',
					server: 'registration'
				}
			},
			{
				name: 'login',
				path: {
					client: 'js/app/user/modules/login/',
					server: 'login'
				}
			}
		],
		defaultModule: 'main'
	}
};

export default config;