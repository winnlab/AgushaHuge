import 'can/'
import 'can/route/'
import 'can/view/'
import 'can/map/define/'

export default can.Control.extend({
	defaults: {
		
	}
}, {
	init: function() {
		this.options.viewpath = this.options.path.client + 'views/';
		
		this.request();
		
		// var view_name = this.options.viewpath + 'index';
		
		// this.element.html(can.view(view_name));
	},
	
	request: function() {
		var	str = this.options.path.server,
			params = ['name', 'id'],
			param,
			that = this,
			reg,
			i;
		
		for(i = params.length; i--;) {
			param = params[i];
			reg = new RegExp(':' + param, 'g');
			str = str.replace(reg, this.options[param]);
		}
		
		can.ajax({
			url: '/' + str,
			success: function(data) {
				that.successRequest(data);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.error(errorThrown);
			}
		});
	},
	
	successRequest: function(data) {
		if(data.err) {
			return console.error(err);
		}
		
		var html = jadeTemplate.get('user/' + this.options.name + '/content', data.data);
		
		this.element.html(html);
		
		this.after_request(data.data);
	},
	
	after_request: function(data) {
		this.variables();
		this.sizes();
		this.plugins();
		
		this.after_init(data);
	},
	
	after_init: function(data) {
		
	},
	
	variables: function() {
		
	},
	
	plugins: function() {
		
	},
	
	sizes: function() {
		
	},
	
	'{window} resize': 'sizes'
});