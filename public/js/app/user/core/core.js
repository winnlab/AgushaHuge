import Router from 'router'
import config from 'rConfig'
import helpers from 'helpers'

import 'js/app/user/core/viewHelpers'

new Router(document.body, config.router);

var Core = can.Control.extend(
	{
		defaults: {
			
		}
	},
	
	{
		init: function () {
			
		},
		
		'#left_menu .close click': function(el) {
			var left_menu = $('.left_menu');
			
			left_menu.toggleClass('small');
		}
	}
);

new Core(document.body);