$('#invite_form').submit(function(ev) {
	var form = $(this);
	invite_validate(form);
	
	if(form.valid() == true) {
		return true;
	} else {
		return false;
	}
});

var validate_login = function(validation, i) {
	rule = 'client[' + i + '][login]';
	validation.rules[rule] = {
		minlength: 3,
		maxlength: 64,
		required: function(element){
			return $("input[name='client[" + i + "][email]']").val().length > 0;
		}
	};
};

var validate_email = function(validation, i) {
	rule = 'client[' + i + '][email]';
	validation.rules[rule] = {
		minlength: 3,
		maxlength: 64,
		email: true,
		required: function(element){
			return $("input[name='client[" + i + "][login]']").val().length > 0;
		}
	};
};

var invite_validate = function(form) {
	var	validation = {rules: {}, messages: {}},
		rule,
		invite_items = $('.invite_item'),
		i;
	
	for(i = invite_items.length; i--;) {
		validate_login(validation, i);
	}
	
	for(i = invite_items.length; i--;) {
		validate_email(validation, i);
	}
	
	validation.ignore = [];
	
	form.validate(validation);
};