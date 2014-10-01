import Router from 'router'
import config from 'rConfig'
import jade from 'jade'
import helpers from 'helpers'

import 'js/app/user/core/viewHelpers'

var Core = can.Control.extend(
	{
		defaults: {
			
		}
	},
	
	{
		init: function () {
			window.jade = jade;
		},
		
		'#left_menu .close click': function(el) {
			var left_menu = $('.left_menu');
			
			left_menu.toggleClass('small');
		}
	}
);

new Core(document.body);

new Router(document.body, config.router);