import 'can/'
import Edit from 'edit'
import 'js/app/admin/components/upload/'
import appState from 'appState'
import _ from 'lodash'

import 'bootstrap-wysihtml5'

export default Edit.extend({
    defaults: {
        viewpath: '/js/app/admin/modules/articles/views/',

        moduleName: 'article',

        successMsg: 'Статья успешно сохранена.',
        errorMsg: 'Ошибка сохранения статьи.',

        form: '.setArticle'
    }
}, {

	init: function(element, options) {
		_.extend(this.options, options);

		var options = this.options,
			data = {
				langs: appState.attr('langs')
			};

		this.ensureObject(options.doc, 'age');
		this.ensureObject(options.doc, 'desc');
		this.ensureObject(options.doc, 'theme');
		this.ensureObject(options.doc, 'type');
		
		data[options.moduleName] = options.doc;

		data['ages'] = options.ages;
		data['themes'] = options.themes;
		data['types'] = options.types;

		this.ageValue = can.compute(null);
		this.themeName = can.compute(null);

		if (options.doc) {
			if (options.doc.age) {
				this.ageValue(options.doc.age.value);
			}
			if (options.doc.theme) {
				this.themeName(options.doc.theme.name);
			}
		}

		data['ageValue'] = this.ageValue;
		data['themeName'] = this.themeName;

		if(!options.doc.attr('_id')) {
			options.doc.attr('active', "true");
		}

		this.loadView(options.viewpath + options.viewName, data);
	},

	ensureObject: function(obj, key) {
		var exists = _.isObject(obj.attr(key));
		if (!exists) {
			obj.attr(key, {});
		}
	},

	'.currentAgeSelect change': function (el) {
		var newVal = el.find('option:selected').data('ages').attr('value');
		this.ageValue(newVal);
	},

	'.currentThemeSelect change': function (el) {
		var newVal = el.find('option:selected').data('themes').attr('name');
		this.themeName(newVal);
	}

});