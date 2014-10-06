import 'can/'
import List from 'list'

import Article from 'js/app/admin/modules/articles/article'
import ArticleModel from 'js/app/admin/modules/articles/articleModel'

import 'css/admin/articles.css!'

// import 'js/app/common/components/articlefilter/'

import AgeModel from 'js/app/admin/modules/category/ageModel'
import ArticleTypeModel from 'js/app/admin/modules/articleTypes/articleTypeModel'
import ThemeModel from 'js/app/admin/modules/category/themeModel'

export default List.extend({
    defaults: {
        viewpath: '/js/app/admin/modules/articles/views/',

        Edit: Article,

        moduleName: 'encyclopedia-article',
        Model: ArticleModel,

        deleteMsg: 'Вы действительно хотите удалить эту статью?',
        deletedMsg: 'Статья успешно удалена!',

        add: '.addArticle',
        edit: '.editArticle',
        remove: '.removeArticle',

        formWrap: '.articleForm',

        parentData: '.article'
    }
}, {
    init: function () {
        var self = this;

        List.prototype.init.call(self);

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
    },

    initSetControl: function (area, doc, entity) {
        var params = {
                ages: this.module.attr('ages'),
                themes: this.module.attr('themes'),
                types: this.module.attr('types'),
                doc,
                entity
            };

        if (this.options.EditHandle) {
            return this.options.EditHandle.init(area, params);
        }
        
        this.options.EditHandle = new this.options.Edit(area, params);
    }
});