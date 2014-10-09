import Controller from 'controller'

import select2 from 'select2'

export default Controller.extend(
	{
        defaults: {
			
        }
    }, {
		plugins: function() {	
			this.select2();
		},
		
		select2: function() {
			var options = {
					width: 'off',
					minimumResultsForSearch: -1,
					formatResult: this.format
				},
				author_select = this.element.find('.author_select'),
				order_select = this.element.find('.order_select');
			
			author_select.select2(options);
			order_select.select2(options);
		},
		
		format: function(state) {
			var	el = $(state.element),
				count = el.data('count'),
				html = 	'<div class="adorable_table encyclopedia_select2_result">' +
							'<div class="adorable_cell">' +
								'<span>' + state.text + '</span>' +
								(typeof(count) != 'undefined' ? '<div class="count">' + count + '</span>' : '') +
							'</div>' +
						'</div>';
			
			return html;
		},
		
		after_init: function(data) {
			
		}
    }
);