import List from 'list'

export default List.extend(
	{
        defaults: {
            viewpath: '/js/app/admin/modules/main/views/',
            viewName: ''
        }
    }, {
        init: function (element, options) {
            console.log('main inited on ', element);
        }
    }
);