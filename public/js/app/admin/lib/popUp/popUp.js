define(
    ['canjs', 'core/appState'],

    function (can, appState) {

        var PopUp = can.Control.extend({
            defaults: {
                viewpath: '/js/app/admin/lib/popUp/views/'
            }
        }, {

            init: function () {
                this.module = new can.Map({
                    'msg': '',
                    'modal': true,
                    'visible': false,
                    'choice': true,
                    'close': true,
                    'content': false
                });

                this.element.append(can.view(this.options.viewpath + 'index.stache', {
                    popUp: this.module,
                    appState: appState
                }));
            },

            show: function (options) {
                this.def = options.def;

                this.module.attr({
                    'msg': options.msg,
                    'choice': typeof options.choice == 'undefined' ? true : options.choice,
                    'visible': true,
                    'msgLength': options.msg.length > 200 ? true : false,
                    'content': false
                });
            },

            info: function (options) {
                this.module.attr({
                    'visible': true,
                    'content': options.content
                });
            },

            '.ok click': function() {
                this.closePopup(0);
            },

            '.yes click': function () {
                this.closePopup(1);
            },

            '.no click': function () {
                this.closePopup(-1);
            },

            '.close click': function () {
                this.closePopup(-1);
            },

            ' keyup': function (el, ev) {
                switch (ev.keyCode) {
                    case 27:
                        this.closePopup(-1);
                        break;
                    case 13:
                        this.closePopup(1);
                        break;
                }
            },

            closePopup: function (type) {

                if (this.def && type === 1) {
                    this.def.resolve();
                }

                if (this.def && type === -1) {
                    this.def.reject();
                }

                this.module.attr({
                    'visible': false,
                    'content': false
                });

                this.def = null
            }

        });

        return new PopUp('body');

    }
)
