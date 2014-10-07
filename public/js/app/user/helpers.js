window.strip_tags = function(str) {	// Strip HTML and PHP tags from a string
	// 
	// +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	
	return str.replace(/<\/?[^>]+>/gi, '');
}

window.escape = function(text) {
	return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
};

window.jadeTemplate = {
	viewPath: '/views/',
	savedViewFuncs: [],
	
	get: function(name, data) {
		if(!(typeof(this.savedViewFuncs[name]) != 'undefined' && this.savedViewFuncs[name])) {
			var response = $.ajax({
				url: this.viewPath + name,
				dataType: 'view',
				async: false
			});
			
			this.savedViewFuncs[name] = new Function('return ' + response.responseText)();
		}
		
		return this.savedViewFuncs[name](data);
	}
}