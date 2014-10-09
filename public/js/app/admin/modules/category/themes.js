import 'can/'
import List from 'list'
import _ from 'lodash'
import appState from 'appState'

import Theme from 'js/app/admin/modules/category/theme'
import themeModel from 'js/app/admin/modules/category/themeModel'

export default List.extend(
	{
		defaults: {
            viewName: 'themeList.stache',

            moduleName: 'theme',
            Model: themeModel,

            Edit: Theme,

            successMsg: 'Сущность успешно сохранена.',
            errorMsg: 'Ошибка сохранения сущности.',

            deleteMsg: 'Вы действительно хотите удалить эту тему?',
            deletedMsg: 'Тема успешно удалена!',

            add: '.addTheme',
            edit: '.redactTheme',
            remove: '.removeTheme',
            rename: '.editTheme',

            formWrap: '.themeForm',

            parentData: '.theme'
        }
	}, {
        init: function () {
            var self = this,
                options = self.options;

            List.prototype.init.apply(self, arguments);            

            self.module.attr('ageData', self.options.ageData);

            can.when(
                self.module.attr(options.moduleName)
            ).then(function () {
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
            this.module.attr('addExisting', null);
        },

		'{add} click': function () {
            if(!this.module.attr('ageData.id')) {
                return alert('Пожалуйста, сначала выберите возраст');
            }

            this.module.attr('addMode', !this.module.attr('addMode'));
        },

        '{edit} click': function (el) {
            var id = this.getDocHandle(el).attr('_id');

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
                            doc.attr('name', response.data.name);
                            return self.processError(response.err);
                        }

                        self.setNotification('success', options.successMsg);
                    })
                    .fail(function (doc) {
                        self.setNotification('error', options.errorMsg);
                    });
            }
        },

        '.activateTheme click': function (el) {
            this.getDocHandle(el).save();
        },

        '.unlinkTheme click': function (el) {
            var self = this,
                options = self.options,
                doc = self.getDocHandle(el),
                index = doc.attr('age_id').indexOf(self.options.ageData.attr('id')),
                removed = doc.attr('age_id').splice(index, 1);

            doc.save()
                .done(function (response) {
                    if(response.err) {
                        doc.attr('age_id').push(removed);
                        return self.processError(response.err);
                    }

                    self.setNotification('success', options.successMsg);
                })
                .fail(function () {
                    self.setNotification('error', options.errorMsg);
                });
        },

        '.confirmTheme click': function (el) {
            var self = this,
                options = self.options,
                link = self.module.attr('addExisting') ? true : false;

            if (link) {
                return self.saveExistingRef(el);
            }
            
            self.createDocument();
        },

        saveExistingRef: function (el) {
            var self = this,
                options = self.options,
                doc = $(el).parents('.row')
                           .find('option:selected')
                           .data(options.moduleName);

            doc.attr('age_id').push(this.options.ageData.attr('id'));
            doc.attr('editable', false);

            doc.save()
                .done(function (response) {
                    if(response.err) {
                        doc.attr('age_id').pop();
                        return self.processError(response.err);
                    }

                    self.setNotification('success', options.successMsg);
                    
                    self.resetObservables();
                })
                .fail(function () {
                    self.setNotification('error', options.errorMsg);
                });
        },

        createDocument: function () {
            var self = this,
                options = self.options,
                doc = new options.Model({
                    active: true,
                    name: this.module.attr('addName'),
                    age_id: [ this.options.ageData.attr('id') ]
                });

            doc.save()
                .done(function (response) {
                    if(response.err) {
                        doc.destroy();
                        return self.processError(response.err);
                    }

                    doc.attr('editable', false);
                    // doc.attr('_id', response.data._id);
                    self.setNotification('success', options.successMsg);
                    
                    self.resetObservables();
                })
                .fail(function () {
                    self.setNotification('error', options.errorMsg);
                });
        },


        '{toList} click': function () {
            this.toListCallback();
        },

        setNotification: function (status, msg) {
            appState.attr('notification', {
                status: status,
                msg: msg
            });
        }
	}
);