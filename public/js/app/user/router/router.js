import $ from 'jquery'
import can from 'can/'
import 'can/route/pushstate/'
import _ from 'underscore'

import Placeholder from 'placeholder'

export default can.Control.extend({
		defaults: {
			viewpath: '../js/app/user/router/views/'
		}
	}, {
		init: function (el, options) {
			this.route = false;
			
			this.Placeholder = new Placeholder();

			var html = can.view(this.options.viewpath + 'route.stache', {
					modules: this.Placeholder.attr('modules')
				}),
				self = this;
			
			$(options.modulesContainer).prepend(html);
			
			can.route.bindings.pushstate.root = options.base;
			can.route.ready();
			
			$('#preloader').fadeOut(300);
		},
		
		'.new_module click': function (el, ev) {
			ev.preventDefault();
			
			var options = this.options,
				href = el.attr('href').split(options.base)[1],
				routeObj = can.route.deparam(href);
			
			try {
				if (!_.isEmpty(routeObj)) {
					can.route.attr(routeObj, true);
				} else {
					throw new  Error("There is no such routing rule for '" + href + "', please check your configuration file");
				}
			} catch (e) {
				console.error(e);
			}
		},

		'/ route': 'routeChanged',
		':module route': 'routeChanged',
		':module/:id route': 'routeChanged',
		
		routeChanged: function (data) {
			var route = data.module + '/' + data.id;
			
			if(this.route === route) {
				return;
			}
			
			this.route = route;
			
			if(!data.module) {
				data.module = this.options.defaultModule;
			}
			
			var modules = this.options.modules,
				moduleName = data.module,
				id = moduleName + (data.id ? '-' + data.id : '');
				module = _.find(modules, function (module) {
					return module.name === moduleName
				});
			
			try {
				if(module) {
					module.id = id;
					
					this.Placeholder.initModule(module);
				} else {
					throw new Error("There is no '" + moduleName + "' module, please check your configuration file");
				}
			} catch (e) {
				console.error(e);
			}
		}
	});