import 'can/'
import List from 'list'
import _ from 'lodash'
import appState from 'appState'

import ageModel from 'js/app/admin/modules/category/ageModel'

export default List.extend(
	{
		defaults: {
            viewName: 'ageList.stache',

            moduleName: 'age',
            Model: ageModel,

            Edit: null,

            successMsg: 'Сущность успешно сохранена.',
            errorMsg: 'Ошибка сохранения сущности.',

            deleteMsg: 'Вы действительно хотите удалить этот возраст?',
            deletedMsg: 'Возраст успешно удален!',

            add: '.addAge',
            edit: '.editAge',
            remove: '.removeAge',

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
                _.each(self.module.attr(options.moduleName), function(year) {
                    year.attr('editable', false);
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
            var doc = el.parents(this.options.parentData)
                       .data(this.options.moduleName);

            if (doc.attr('editable') === false) {
                doc.attr('editable', true);

                this.options.age_id(doc.attr('_id'));
            } else {
                doc.attr('editable', false);

                doc.save();
            }
        },

        '.activateAge click': function (el) {
            var doc = el.parents(this.options.parentData)
                       .data(this.options.moduleName);

            doc.save();
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
                        self.processError(response.err)
                    }

                    doc.attr('_id', response.data._id);
                    self.setNotification('success', options.successMsg);

                    self.resetObservables();
                })
                .fail(function (doc) {
                    self.setNotification('error', options.errorMsg);
                });
        },

        setNotification: function (status, msg) {
            appState.attr('notification', {
                status: status,
                msg: msg
            });
        },

        processError: function (err) {
            var msg;

            if(err.errors && err.errors.title) {
                msg = err.errors.title.message;
            }

            if(!msg) {
                msg = err.message || err;
            }
            
            alert(msg);
            this.setNotification('error', msg);
        }
	}
);