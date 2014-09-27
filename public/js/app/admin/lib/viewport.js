define([
    'canjs'
],
    function (can) {

        var Viewprot = can.Control.extend({
            init: function () {
                this.state = new can.Map({
                    width: 0,
                    height: 0
                });

                this._setViewWidth();
                this._setViewHeight();
            },

            _setViewWidth: function () {
                var width = (window.innerWidth
                    ? window.innerWidth
                    : (document.documentElement.clientWidth
                        ? document.documentElement.clientWidth
                        : document.body.offsetWidth));
                if (width < 1224) {
                    width = 1224;                    
                }

                this.state.attr('width', width);
            },

            _setViewHeight: function () {
                var viewportHeight = (window.innerHeight
                    ? window.innerHeight
                    : (document.documentElement.clientHeight
                        ? document.documentElement.clientHeight
                        : document.body.offsetHeight));

                if (viewportHeight < 650) {
                    viewportHeight = 650
                }

                this.state.attr('height', viewportHeight);
            },

            '{window} resize': function () {
                this._setViewWidth();
                this._setViewHeight();
            },

            getViewportWidth: function () {
                return this.state.attr('width');
            },

            getViewportHeight: function () {
                return this.state.attr('height');
            }
        });
        var viewport = new Viewprot('body');
        window['viewport'] = viewport;
        return viewport;

    }
);
