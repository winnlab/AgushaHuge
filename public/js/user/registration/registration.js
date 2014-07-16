$('#registration_form').submit(function(ev) {
	var form = $(this);
	registration_validate(form);
	
	if(form.valid() == true) {
		return true;
	} else {
		return false;
	}
});

var registration_validate = function(form) {
	var	validation = {rules: {}, messages: {}},
		rule;
	
	rule = 'login';
	validation.rules[rule] = {
		required: true,
		minlength: 3,
		maxlength: 64
	};
	
	rule = 'email';
	validation.rules[rule] = {
		required: true,
		minlength: 3,
		maxlength: 64,
		email: true
	};
	
	validation.ignore = [];
	
	form.validate(validation);
};