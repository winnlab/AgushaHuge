import List from 'list'

export default List.extend({
        defaults: {
            viewpath: 'js/admin/app/modules/tales/views/'
        }
    }, {
        init: function () {
            console.log('main inited!');
        }
    }
});