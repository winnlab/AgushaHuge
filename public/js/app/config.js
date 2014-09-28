System.config({
	baseURL: "/",
	paths: {
		"css-admin/*": "css/admin/*css",
		"jquery": "js/plugins/jquery/dist/jquery.min.js",
		"can/*": "js/plugins/CanJS/*.js",
		"adminlte": "js/plugins/adminlte/js/AdminLTE/app.js",
		"bootstrap": "js/plugins/adminlte/js/bootstrap.min.js",
		"slimscroll": "js/plugins/adminlte/js/plugins/slimScroll/jquery.slimscroll.min.js",
		"iCheck": "js/plugins/adminlte/js/plugins/iCheck/icheck.min.js",
		"velocity": "js/plugins/velocity/velocity.min.js",
		"velocity-ui": "js/plugins/velocity/velocity.ui.min.js",
		"underscore": "js/plugins/underscore/underscore-min.js",

		"adminlte-css/*": "js/plugins/adminlte/css/*css",
		"bootstrap-wysihtml-css": "js/plugins/adminlte/css/bootstrap-wysihtml5/bootstrap3-wysihtml5.min.css",

		"router": 'js/app/admin/router/router.js',
		"placeholder": 'js/app/admin/router/placeholder.js',

		"core": 'js/app/admin/core/core.js',
		"appState": 'js/app/admin/core/appState.js',
		"rConfig": 'js/app/admin/core/config.js',

		"list": 'js/app/admin/lib/list/list.js',
		"baseModel": 'js/app/admin/lib/model/baseModel.js'
	},
	map: {
		"can/util/util": "can/util/jquery/jquery",
		"jquery/jquery": "jquery",
		"$": "jquery"
	},
	ext: {
		css: 'js/plugins/steal/css'
	},
	meta: {
		"can/*": {
			deps: [
				'jquery',
				'can/route/pushstate/pushstate'
			]
		},
		"core": {
			deps: [
				'jquery',
				'can/',
				'adminlte',
				'css-admin/global.css!',
				'router'
			]
		},
		"placeholder": {
			format: "steal"
		},
		slimscroll: {
			deps: ["jquery"]
		},
		bootstrap: {
			deps: ["jquery"]
		},
		adminlte: {
			format: "global",
			deps: [
				"jquery",
				"bootstrap",
				"iCheck",
				"slimscroll",
				"adminlte-css/AdminLTE.css!",
				"adminlte-css/font-awesome.min.css!",
				"adminlte-css/ionicons.min.css!",
				"adminlte-css/bootstrap.min.css!"
			]
		}
	}
});