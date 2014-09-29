import can from 'can/'
import List from 'list'

import themeItem from 'js/app/admin/modules/category/theme'
import themeModel from 'js/app/admin/modules/category/themeModel'

export default List.extend(
	{
		defaults: {
            viewName: 'themeList.stache',

            Edit: themeItem,

            moduleName: 'themes',
            Model: themeModel,

            deleteMsg: 'Вы действительно хотите удалить эту тему?',
            deletedMsg: 'Тема успешно удалена!',

            add: '.addYears',
            edit: '.editYears',
            remove: '.removeYears',

            formWrap: '.themeForm',

            parentData: '.theme'
        }
	}, {
		'{add} click': function () {
            this.setDocCallback(0);
        },

        '{edit} click': function (el) {
            var id = el.parents(this.options.parentData)
                .data(this.options.moduleName).attr('_id');
            this.setDocCallback(id);
        },

        '{toList} click': function () {
            this.toListCallback();
        }
	}
);