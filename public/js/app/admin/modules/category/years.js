import 'can/'
import List from 'list'
import _ from 'lodash'

import yearsItem from 'js/app/admin/modules/category/yearsItem'
import yearsModel from 'js/app/admin/modules/category/yearsModel'

export default List.extend(
	{
		defaults: {
            viewName: 'yearsList.stache',

            Edit: yearsItem,

            moduleName: 'years',
            Model: yearsModel,

            deleteMsg: 'Вы действительно хотите удалить этот возраст?',
            deletedMsg: 'Возраст успешно удален!',

            add: '.addYears',
            edit: '.editYears',
            remove: '.removeYears',

            formWrap: '.yearsForm',

            parentData: '.years'
        }
	}, {
        init: function () {
            List.prototype.init.apply(this, arguments);
        },

		'{add} click': function () {
            this.setDocCallback(0);
        },

        '{edit} click': function (el) {
            var id = el.parents(this.options.parentData)
                       .data(this.options.moduleName).attr('_id');

            var doc = _.find(this.module.attr(this.options.moduleName), function (doc) {
                return doc && doc.attr('_id') === id;
            });
            

        }
	}
);