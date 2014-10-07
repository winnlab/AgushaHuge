import 'adminlte'

import Router from 'router'
import config from 'rConfig'
import 'jquery'

import 'js/app/admin/core/viewHelpers'
import 'js/app/admin/components/notification/'

import 'css/admin/global.css!'


// Alert!! Benachrichtigung!! Alerte!! //

// Extending jQuery serializeArray to make it return
// `false` in unchecked checkboxes //
var originalSerializeArray = $.fn.serializeArray;
$.fn.extend({
    serializeArray: function () {
        var brokenSerialization = originalSerializeArray.apply(this);
        var checkboxValues = $(this).find('input[type=checkbox]').map(function () {
            return { 'name': this.name, 'value': this.checked };
        }).get();
        var checkboxKeys = $.map(checkboxValues, function (element) { return element.name; });
        var withoutCheckboxes = $.grep(brokenSerialization, function (element) {
            return $.inArray(element.name, checkboxKeys) == -1;
        });

        return $.merge(withoutCheckboxes, checkboxValues);
    }
});
// End //

new Router(document.body, config.router);