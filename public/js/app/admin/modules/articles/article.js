import 'can/'
import Edit from 'edit'
import 'js/app/admin/components/upload/'

import 'js/plugins/bootstrap-wysihtml5/dist/bootstrap-wysihtml5-0.0.2.css!'
import 'bootstrap-wysihtml5'

import AgeModel from 'js/app/admin/modules/category/ageModel'
import ArticleTypeModel from 'js/app/admin/modules/articleTypes/articleTypeModel'
import ThemeModel from 'js/app/admin/modules/category/themeModel'

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
		var self = this;
		
		self.module = new can.Map({});
		self.module.attr('ages', new can.List);
		self.module.attr('themes', new can.List);
		self.module.attr('types', new can.List);

		AgeModel.findAll({active: true}, function (docs) {
			$.each(docs, function(i, doc) {
				self.module.attr('ages').push(doc);
			});
		});

		ThemeModel.findAll({active: true}, function (docs) {
			$.each(docs, function(i, doc) {
				self.module.attr('themes').push(doc);
			});
		});

		ArticleTypeModel.findAll({}, function (docs) {
			$.each(docs, function(i, doc) {
				self.module.attr('types').push(doc);
			});
		});

		Edit.prototype.init.call(this);
	},

	loadView: function (path, data) {
		this.module.attr(this.moduleName, data[this.moduleName]);
		this.element.html(can.view(path, this.module));
	}

});