import 'can/'
import Edit from 'edit'

import 'js/plugins/bootstrap3-wysiwyg/dist/bootstrap3-wysihtml5.min.css!'
// import Handlebars from 'js/plugins/handlebars/handlebars.runtime.js'
import 'bootstrap-wysihtml5'

export default Edit.extend({
    defaults: {
        viewpath: '/js/app/admin/modules/faqs/views/',

        moduleName: 'faq',

        successMsg: 'Статья успешно сохранена.',
        errorMsg: 'Ошибка сохранения статьи.',

        form: '.setFaq'
    }
}, {
	init: function () {
		Edit.prototype.init.call(this);

		if(!this.options.doc.attr('_id')) {
            this.options.doc.attr('active', true);
			this.options.doc.attr('position', 99);
		}
	}
});