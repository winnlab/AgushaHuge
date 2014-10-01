import can from 'can/'
import Ages from 'js/app/admin/modules/category/ages'
import Themes from 'js/app/admin/modules/category/themes'

import 'css/admin/category.css!'

export default can.Control.extend(
	{
		defaults: {
	        viewpath: '../js/app/admin/modules/category/views/'
	    }
	}, {
		init: function () {

            var self = this,
                options = self.options,
                ageData = new can.Map({
                    id: null,
                    name: ''
                });

            self.element.html(
                can.view(options.viewpath + 'index.stache', {})
            );

            new Ages(self.element.find('#ageWrap'), {
                viewpath: options.viewpath,
                ageData
            });

            new Themes(self.element.find('#themeWrap'), {
                viewpath: options.viewpath,
                ageData
            });

        }
	}
);