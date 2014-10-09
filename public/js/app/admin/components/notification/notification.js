import 'jquery'
import 'can/'
import 'can/map/define/'
import 'can/map/delegate/'
import appState from 'appState'
import 'css/admin/components/notification.css!'

var Notification = can.Map.extend({
	notification: {
		className: '',
		iconName: ''
	},
	visible: false,
	hide: function () {
		var self = this,
			time = this.attr('notification.time');

		time = time ? time : 3000;

		if (self.attr('notification.status')) {
			time += 5000;
		}

		setTimeout(function() {
			self.attr('visible', false);
		}, time);
	}				
});

var notification = new Notification();		

appState.delegate('notification', 'set', function() {		
	var state = appState.attr('notification');

	notification.attr({
		'notification': {
			className: state.status === 'success' ? 'alert-success' : 'alert-danger',
			iconName: state.status === 'success' ? 'fa-check' : 'fa-ban',
			msg: state.msg
		},
		'visible': true
	});
	
	notification.hide();
});

can.Component.extend({
	tag: 'notification',
	template: 
		'{{#if visible}}'+
			'<div id="appNotification" class="alert {{notification.className}} alert-dismissable">' + 
				'<i class="fa {{notification.iconName}}"></i>' +
				'<b>Внимание:&nbsp;</b>' +
				'{{notification.msg}}' +
			'</div>' + 				
		'{{/if}}',
	scope: notification,
	events: {
		click: function () {
			this.scope.attr("visible", false);
		}
	}
});

var module = function () {			
	var template = can.mustache("<notification></notification>");
	$(document.body).append(template());
};

module();