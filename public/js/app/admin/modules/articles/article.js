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

        removeAnswerMsg: 'Удалить ответ?',

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

	'{form} submit': function (el, ev) {
		ev.preventDefault();

		var self = this,
			options = self.options,
			data = this.getDocData(el),
			doc = options.doc;

		doc.attr(data);

		doc.save()
			.done(function (response) {
				if (response.err) {
                    return self.processError(response.err);
                }

				options.entity(doc.attr('_id'));

				if (options.setRoute) {
					can.route.attr({'entity_id': doc.attr('_id')});
				}

				self.setNotification('success', options.successMsg);
			})
			.fail(function () {
				self.setNotification('error', options.errorMsg);
			});

	},'.currentAgeSelect change': function (el) {
		var newVal = el.find('option:selected').data('ages').attr('value');
		this.ageValue(newVal);
	},

	'.currentThemeSelect change': function (el) {
		var newVal = el.find('option:selected').data('themes').attr('name');
		this.themeName(newVal);
	},

	'.addAnswer click': function (el) {
		var answers = this.options.doc.attr('answer');
		if(!answers) {
			this.options.doc.attr('answer', new can.List);
			answers = this.options.doc.attr('answer');
		}
		answers.push({text: '', score: 0});
	},

	'.removeAnswer click': function (el) {
		if (confirm(this.options.removeAnswerMsg)) {
			var item = $(el).parents('.answer').data('answer'),
				answ = this.options.doc.attr('answer'),
				index = answ.indexOf(item);

			if(index > -1) {
				answ.splice(index, 1);
			}
		}
	}

});