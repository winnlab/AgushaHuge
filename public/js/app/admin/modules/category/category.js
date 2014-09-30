import can from 'can/'
import Years from 'js/app/admin/modules/category/ages'
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
                age_id = can.compute();

            self.element.html(
                can.view(options.viewpath + 'index.stache', {})
            );

            new Years(self.element.find('#ageWrap'), {
                viewpath: options.viewpath,
                age_id
            });

            new Themes(self.element.find('#themeWrap'), {
                viewpath: options.viewpath,
                age_id
            });

        }
	}
);