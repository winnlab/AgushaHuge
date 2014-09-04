requirejs.config({
    baseUrl: './',
    paths: {
        plugin: '../plugins',
        jquery: '../jquery.min',
        jqueryUi: 'jquery-ui-1.10.3.min'
        can: '../plugins/canjs.com-2.1.3/can.jquery.com',
        bootstrap: 'bootstrap',
        iCheck: 'plugins/iCheck/icheck.min.js'
    }
});

requirejs ['jquery', 'can', 'bootstrap', 'jqueryUi', 'iCheck'], ($, can, bootstrap, jquery-ui, iCheck) ->
    Core = can.Control.extend
        defaults: 
            inited: false
    ,
        init: (element, options) ->
            self = @
            console.log 'bla'

core = new Core $('body')