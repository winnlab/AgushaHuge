import 'can/'
import List from 'list'

import Article from 'js/app/admin/modules/articles/article'
import ArticleModel from 'js/app/admin/modules/articles/articleModel'

import 'css/admin/articles.css!'

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
}, {});