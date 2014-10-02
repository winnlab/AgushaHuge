import 'can/'
import List from 'list'
import _ from 'lodash'
import appState from 'appState'

import Age from 'js/app/admin/modules/category/age'
import ageModel from 'js/app/admin/modules/category/ageModel'

export default List.extend(
	{
		defaults: {
            viewName: 'ageList.stache',

            moduleName: 'age',
            Model: ageModel,

            Edit: Age,

            successMsg: 'Сущность успешно сохранена.',
            errorMsg: 'Ошибка сохранения сущности.',

            deleteMsg: 'Вы действительно хотите удалить этот возраст?',
            deletedMsg: 'Возраст успешно удален!',

            add: '.addAge',
            edit: '.redactAge',
            remove: '.removeAge',
            rename: '.editAge',

            formWrap: '.ageForm',

            parentData: '.age'
        }
	}, {
        init: function () {
            List.prototype.init.apply(this, arguments);
            var self = this,
                options = self.options;

            can.when(
                self.module.attr(options.moduleName)
            ).then(function () {
                _.each(self.module.attr(options.moduleName), function(entity) {
                    entity.attr('editable', false);
                    if(!entity.attr('icon')) {
                        entity.attr('icon', {})
                    };

                    if(!entity.attr('desc')) {
                        entity.attr('desc', {});
                    }

                    if(!entity.attr('desc.image')) {
                        entity.attr('desc.image', {});
                    }
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

        '{toList} click': function () {
            this.toListCallback();
        },

		'{add} click': function () {
            this.module.attr('addMode', !this.module.attr('addMode'));
        },

        '{edit} click': function (el) {
            var id = el.parents(this.options.parentData)
                     .data(this.options.moduleName).attr('_id');

            this.setDocCallback(id);
        },

        '{rename} click': function (el) {
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

        '.activateAge click': function (el) {
            this.getDocHandle(el).save();
        },

        '.confirmAge click': function () {
            var options = this.options,
                self = this,
                value = 1;

            try {
                value = parseInt(self.module.attr('addName'));
            } catch (e) {}
                

            var doc = new options.Model({
                active: true,
                value
            });

            doc.save()
                .done(function (response) {
                    if(response.err) {
                        doc.destroy();
                        return self.processError(response.err);
                    }

                    doc.attr('_id', response.data._id);
                    self.setNotification('success', options.successMsg);

                    self.resetObservables();
                })
                .fail(function (doc) {
                    self.setNotification('error', options.errorMsg);
                });
        },

        '.ageChildren click': function (el) {
            var doc = el.parents(this.options.parentData)
                       .data(this.options.moduleName);

            this.options.ageData.attr({
                id: doc.attr('_id'),
                name: doc.attr('value')
            });
        },

        setNotification: function (status, msg) {
            appState.attr('notification', {
                status: status,
                msg: msg
            });
        }
	}
);