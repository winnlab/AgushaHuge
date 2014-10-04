import select2 from 'select2'

import Controller from 'controller'

var Product = can.Model.extend({
	findAll: 'POST /products/findAll',
	parseModels: function(data) {
		return data.data.products;
	}
}, {});

export default Controller.extend(
	{
        defaults: {
			
        }
    }, {
		after_init: function(data) {
			var that = this,
				products,
				html;
			
			this.first_call = true;
			
			if(data) {
				products = data.products;
			} else {
				products = app.products;
			}
			
			var ViewModel = can.Map.extend({
				define: {
					age: {
						value: null
					},
					
					category: {
						value: null
					},
					
					products: {
						value: new can.List(products),
						get: function(currentValue) {
							var options = {
								age: this.attr('age'),
								category: this.attr('category')
							};
							
							if(!that.first_call) {
								currentValue.replace(Product.findAll(options));
							}
							
							return currentValue;
						}
					}
				}
			});
			
			this.data = new ViewModel();
			
			var product_mustache = $('#product_mustache');
			
			if(!product_mustache.length) {
				html = jadeTemplate.get('user/products/product_mustache');
			} else {
				html = product_mustache.html();
			}
			
			can.view.mustache('product', html);
			
			$('#products_container').html(can.view('product', this.data, {
				ageValue: function(options) {
					if(options.context.age) {
						return options.context.age.value < 12 ? options.fn() : options.inverse();
					}
					
					return options.fn();
				}
			}));
			
			this.first_call = false;
		},
		
		variables: function() {
			this.about_ages = this.element.find('#about_ages');
			this.about_blocks = this.element.find('.about_block');
		},
		
		plugins: function() {	
			this.select2();
		},
		
		select2: function() {
			var	selector = this.element.find('.products_age_select');
			
			selector.select2({
				width: 'off',
				formatSelection: this.format,
				formatResult: this.format,
				minimumResultsForSearch: -1
			});
		},
		
		format: function(state) {
			var	el = $(state.element),
				normal = el.data('icon.normal'),
				hover = el.data('icon.hover'),
				html = 	'<div class="part left">' +
							'<img class="icon normal" src="' + normal + '" />' +
							'<img class="icon hover" src="' + hover + '" />' +
						'</div>' +
						'<div class="part right adorable_table">' +
							'<div class="adorable_cell">' +
								state.text +
							'</div>' +
						'</div>';
			
			return html;
		},
		
		'.products_age_select change': function(el, ev) {
			var val = ev.val;
			
			this.data.attr('age', val);
			
			if(typeof(val) != 'undefined' && val != null) {
				this.about_ages.addClass('active');
				this.about_blocks.removeClass('active');
				this.about_blocks.filter('#age_' + val).addClass('active');
			} else {
				this.about_ages.removeClass('active');
			}
		},
		
		'.choose_category click': function(el) {
			var val = el.data('category'),
				choose_categories = this.element.find('.choose_category');
			
			choose_categories.removeClass('active');
			el.addClass('active');
			
			this.data.attr('category', val);
		}
    }
);