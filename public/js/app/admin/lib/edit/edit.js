import 'can/'
import 'appState'

export default can.Control.extend({
	defaults: {
		viewpath: '',
        viewName: 'set.stache',
		moduleName: 'doc',
		successMsg: 'Сущность успешно сохранена.',
		errorMsg: 'Ошибка сохранения сущности.',
        // Selectors
		form: '',
		// is change entityId param in can.route
		setRoute: true
	}
}, {
	init: function () {
		var options = this.options,
			data = {
				langs: appState.attr('langs')
			};
		data[options.moduleName] = options.doc;
		this.element.html(can.view(options.viewpath + options.viewName, data));
	},

	'{form} submit': function (el, ev) {
		ev.preventDefault();

		var self = this,
			options = self.options,
			data = this.getDocData(el),
			doc = options.doc;

		doc.attr(data);

		doc.save()
			.done(function(doс) {
				options.entity(doc.attr('_id'));
				if (options.setRoute) {
					can.route.attr({'entity_id': doc.attr('_id')});
				}
				self.setNotification('success', options.successMsg);
			})
			.fail(function (doc) {
				self.setNotification('error', options.errorMsg);
			});

	},

	getDocData: function (el) {
		return can.deparam(el.serialize())
	},

	setNotification: function (status, msg) {
		appState.attr('notification', {
			status: status,
			msg: msg
		});
	}
});