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
					server: ':name'
				}
			},
			{
				name: 'login',
				path: {
					client: 'js/app/user/modules/login/',
					server: ':name'
				}
			},
			{
				name: 'products',
				path: {
					client: 'js/app/user/modules/products/',
					server: ':name'
				}
			}
		],
		defaultModule: 'main'
	}
};

export default config;