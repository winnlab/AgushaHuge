import $ from 'jquery'
import can from 'can/'
import 'can/route/pushstate/'
import _ from 'underscore'

import Placeholder from 'placeholder'

export default can.Control.extend({
		defaults: {
			viewpath: '../js/app/admin/router/views/'
		}
	}, {
		init: function (el, options) {

			this.Placeholder = new Placeholder();

			var html = can.view(this.options.viewpath + 'route.stache', {
					modules: this.Placeholder.attr('modules')
				}),
				self = this;

			$(options.modulesContainer).html(html);

			can.route.bindings.pushstate.root = options.base;
			can.route.ready();

			$('preloader').fadeOut(300);
		},

		'.module click': function (el, ev) {
			ev.preventDefault();

			var options = this.options,
				href = el.attr('href').split(options.base)[1],
				routeObj = can.route.deparam(href);

			try {
				if (!_.isEmpty(routeObj)) {
					can.route.attr(routeObj, true);
				} else {
					throw new  Error("There now such routing rule for '" + href + "', please check your configuration file");
				}
			} catch (e) {
				console.error(e);
			}
		},

		':module route': 'routeChanged',
		':module/:id route': 'routeChanged',
		':module/:action/:entity_id route': 'routeChanged',

		':module/encyclopedia/:id route': 'routeChanged',
		':module/encyclopedia/:action/:entity_id route': 'routeChanged',

		':module/product/:id route': 'routeChanged',
		':module/product/:action/:entity_id route': 'routeChanged',

		':module/:id/:action/:entity_id route': 'routeChanged',

		routeChanged: function (data) {				
			var modules = this.options.modules,
				moduleName = data.module,
				id = moduleName + (data.id ? '-' + data.id : '');
				module = _.find(modules, function (module) {
					return module.name === moduleName
				});

			try {
				if (module) {
					this.Placeholder.initModule(module, id);
				} else {
					throw new Error("There no such module '" + moduleName + "', please check your configuration file");
				}
			} catch (e) {
				console.error(e);
			}
		}
	});