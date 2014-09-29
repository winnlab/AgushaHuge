import List from 'list'

export default List.extend(
	{
        defaults: {
            viewpath: 'js/admin/app/modules/tales/views/'
        }
    }, {
        init: function (element, options) {
            console.log('main inited on ', element);
        }
    }
);