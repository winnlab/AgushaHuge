import 'can/'
import Edit from 'edit'
import 'js/app/admin/components/upload/'
import appState from 'appState'

import 'js/plugins/bootstrap-wysihtml5/dist/bootstrap-wysihtml5-0.0.2.css!'
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

	init: function() {
		if(this.inited) {
			_.extend(this.options, options);
		}

		var options = this.options,
			data = {
				langs: appState.attr('langs')
			};

		data[options.moduleName] = options.doc;

		data['ages'] = options.ages;
		data['themes'] = options.themes;
		data['types'] = options.types;

		this.currentAge = can.compute(options.doc.age.age_id);
		data['currentAge'] = this.currentAge;

		this.loadView(options.viewpath + options.viewName, data);

		this.inited = true;
	},

	'.currentAgeSelect change': function (el) {
		this.currentAge(el.val());
		var newVal = el.find('option:selected').data('ages').attr('value');
		$('.ageValue').val(newVal);
	},

	'.currentThemeSelect change': function (el) {
		var newVal = el.find('option:selected').data('themes').attr('name');
		$('.themeName').val(newVal);
	}

});