import 'can/'
import List from 'list'
import _ from 'lodash'
import appState from 'appState'

import themeModel from 'js/app/admin/modules/category/themeModel'

export default List.extend(
	{
		defaults: {
            viewName: 'themeList.stache',

            moduleName: 'theme',
            Model: themeModel,

            Edit: null,

            successMsg: 'Сущность успешно сохранена.',
            errorMsg: 'Ошибка сохранения сущности.',

            deleteMsg: 'Вы действительно хотите удалить эту тему?',
            deletedMsg: 'Тема успешно удалена!',

            add: '.addTheme',
            edit: '.editTheme',
            body: '.bodyTheme',
            remove: '.removeTheme',
            activate: '.activateTheme',
            confirm: '.confirmTheme',

            formWrap: '.themeForm',

            parentData: '.theme'
        }
	}, {
        init: function () {
            List.prototype.init.apply(this, arguments);

            var self = this;            

            this.options.age_id.bind("change", function(ev, newVal, oldVal){
                self.getData(newVal);
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

        getData: function (age_id) {
            this.module.attr(this.options.moduleName, new this.options.Model.List({age_id}));
        },

		'{add} click': function () {
            if(!this.module.attr('age_id')) {
                alert('Пожалуйста, сначала выберите возраст');
            }
            this.module.attr('addMode', !this.module.attr('addMode'));
        },

        '{edit} click': function (el) {
            var doc = el.parents(this.options.parentData)
                       .data(this.options.moduleName);

            if (doc.attr('editable') === false) {
                doc.attr('editable', true);
            } else {
                doc.attr('editable', false);

                doc.save();
            }
        },

        '{activate} click': function (el) {
            var doc = el.parents(this.options.parentData)
                       .data(this.options.moduleName);

            doc.save();
        },

        '{confirm} click': function () {
            var options = this.options,
                self = this,
                create = this.module.attr('addExisting') ? true : false;

            var doc = create
                ? this.saveExistingRef()
                : this.createDocument();
            return;

            doc.save()
                .done(function (response) {
                    doc.attr('_id', response.data._id);
                    self.setNotification('success', options.successMsg);
                    
                    selfresetObservables();
                })
                .fail(function (doc) {
                    self.setNotification('error', options.errorMsg);
                });
        },

        saveExistingRef: function () {

        },

        createDocument: function () {
            doc = new options.Model({
                active: true,
                name: this.module.attr('addName')
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