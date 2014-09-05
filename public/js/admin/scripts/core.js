var core;

requirejs.config({
  baseUrl: './',
  paths: {
    plugin: '../plugins',
    jquery: '../jquery.min',
    jqueryUi: 'jquery-ui-1.10.3.min',
    can: '../plugins/canjs.com-2.1.3/can.jquery.com',
    bootstrap: 'bootstrap',
    iCheck: 'plugins/iCheck/icheck.min.js'
  }
});

requirejs(['jquery', 'can', 'bootstrap', 'jqueryUi', 'iCheck'], function($, can, bootstrap, jqueryui, iCheck) {
  var Core;
  return Core = can.Control.extend({
    defaults: {
      inited: false
    }
  }, {
    init: function(element, options) {
      var self;
      self = this;
      return console.log('blabla');
    }
  });
});

core = new Core($('body'));
