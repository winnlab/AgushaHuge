import 'can/'
import List from 'list'
import _ from 'lodash'
import appState from 'appState'

import articleTypeModel from 'js/app/admin/modules/articleTypes/articleTypeModel'

export default List.extend(
	{
		defaults: {
            viewpath: '/js/app/admin/modules/articleTypes/views/',
            viewName: 'index.stache',

            moduleName: 'articleType',
            Model: articleTypeModel,

            Edit: null,

            successMsg: 'Сущность успешно сохранена.',
            errorMsg: 'Ошибка сохранения сущности.',

            deleteMsg: 'Вы действительно хотите удалить этот возраст?',
            deletedMsg: 'Возраст успешно удален!',

            add: '.addArticleType',
            edit: '.editArticleType',
            remove: '.removeArticleType',

            formWrap: '.articleTypeForm',

            parentData: '.articleType'
        }
	}, {
        init: function () {
            List.prototype.init.apply(this, arguments);
            var self = this,
                options = self.options;

            can.when(
                self.module.attr(options.moduleName)
            ).then(function () {
                self.resetObservables();
                _.each(self.module.attr(options.moduleName), function(entity) {
                    entity.attr('editable', false);
                });
            });
        },

        loadView: function () {
            this.resetObservables();
            List.prototype.loadView.call(this);
        },

        resetObservables: function () {
            this.module.attr('addMode', false);
            this.module.attr('addName', '');
        },

		'{add} click': function () {
            this.module.attr('addMode', !this.module.attr('addMode'));
        },

        '{edit} click': function (el) {
            var self = this,
                options = self.options,
                doc = self.getDocHandle(el);

            if (doc.attr('editable') === false) {
                doc.attr('editable', true);
            } else {
                doc.attr('editable', false);

                doc.save()
                    .done(function (response) {
                        if(response.err) {
                            doc.attr('value', response.data.value);
                            return self.processError(response.err);
                        }

                        self.setNotification('success', options.successMsg);
                    })
                    .fail(function (doc) {
                        self.setNotification('error', options.errorMsg);
                    });
            }
        },

        '.confirmArticleType click': function () {
            var options = this.options,
                self = this,
                name = self.module.attr('addName');

            var doc = new options.Model({
                name
            });

            doc.save()
                .done(function (response) {
                    if(response.err) {
                        doc.destroy();
                        return self.processError(response.err);
                    }

                    doc.attr('editable', false);
                    self.setNotification('success', options.successMsg);

                    self.resetObservables();
                })
                .fail(function (doc) {
                    self.setNotification('error', options.errorMsg);
                });
        }
	}
);