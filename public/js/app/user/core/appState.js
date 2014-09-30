import can from 'can/'

var AppState = can.Map.extend({
	define: {
		notification: {
			value: {},
			serialize: false
		}
	},
	langs: window.langs,
	locale: window.locale
});

export default new AppState();