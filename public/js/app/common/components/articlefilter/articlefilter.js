import 'jquery'
import 'can/'
import appState from 'appState'
import 'css/common/components/articlefilter.css!'

var currentHeight = function () {
	return $('.af-wrap .col-md-2').width();
};

can.Component.extend({
	tag: 'articlefilter',
	template: can.view('/js/app/common/components/articlefilter/views/articlefilter.stache'),
	scope: {
		visible: false,
		height: currentHeight,
		showTypes: false,
		currents: {
			age: null,
			theme: null,
			type: null
		}
	},
	events: {
		'{window} resize': function () {
			this.scope.attr("height", currentHeight());
		},

		'.t-af-expand click': function () {
			this.scope.attr("visible", true);
		},

		'.t-af-close click': function () {
			this.scope.attr("visible", false);
		},

		'.af-item click': function (el) {
			var name = el.data('name'),
				attrName = "currents." + name,
				newVal = el.data(name + 's').attr(el.data('id'));

			this.scope.attr(attrName, newVal);
		},

		'.t-reset-all click': function () {
			this.giveAwayData();
		},

		'.t-submit click': function () {
			this.giveAwayData(this.scope.attr('currents'));
		},

		giveAwayData: function (results = false) {
			try {
			    this.scope.attr("visible", false);
			    this.scope.attr('fn').exec(results);
			} catch(e) {
				console.error(e);
				console.error("`articlefilter` component seems do not have callback argument (fn) or it has no function in `exec` property");
			}
		}
	}
});