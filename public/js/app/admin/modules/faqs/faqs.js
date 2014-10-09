import 'can/'
import List from 'list'

import FaqModel from 'js/app/admin/modules/faqs/faqModel'
import Faq from 'js/app/admin/modules/faqs/faq'

export default List.extend(
	{
		defaults: {
            viewpath: '/js/app/admin/modules/faqs/views/',
            viewName: 'index.stache',

            moduleName: 'faq',
            Model: FaqModel,

            Edit: Faq,

            add: '.addFaq',
            edit: '.editFaq',
            remove: '.removeFaq',

            formWrap: '.faqForm',

            parentData: '.faq'
        }
	},
    {
        '.activateFaq click': function (el) {
            this.getDocHandle(el).save();
        }
    }
);