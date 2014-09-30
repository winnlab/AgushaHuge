import 'jquery'
import 'can/'
import 'can/map/define/'
import 'can/map/delegate/'
import appState from 'appState'
import 'css/admin/components/notification.css!'

var Notification = can.Map.extend({
	notification: {},
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
	notification.attr({
		'notification': appState.attr('notification'),
		'visible': true
	});
	
	notification.hide();
});

can.Component.extend({
	tag: 'notification',
	template: 
		'{{#if visible}}'+
			'<div id="appNotification" class="alert {{getClass}} alert-dismissable">' + 
				'<i class="fa {{getIcon}}"></i>' +
				'<b>Внимание:&nbsp;</b>' +
				'{{notification.msg}}' +
			'</div>' + 				
		'{{/if}}',
	scope: notification,
	helpers: {
		getClass: function () {
			var status = this.attr('notification.status'),
				className = status === 'success' ? 'alert-success' : 'alert-danger';
			return className;
		},
		getIcon: function () {
			var status = this.attr('notification.status'),
				iconName = status === 'success' ? 'fa-check' : 'fa-ban';
			return iconName;
		}
	},
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

export default module;