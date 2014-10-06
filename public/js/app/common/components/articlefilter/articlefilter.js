import 'jquery'
import 'can/'
import appState from 'appState'
import 'css/common/components/articlefilter.css!'

can.Component.extend({
	tag: 'articlefilter',
	template: can.view('/js/app/common/components/articlefilter/views/articlefilter.stache'),
	scope: {
		visible: false,
		showTheme: false
	},
	events: {
		".t-af-expand click": function () {
			this.scope.attr("visible", true);
		}
	}
});