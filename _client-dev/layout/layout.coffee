Layout = can.Control.extend
    defaults: 
        inited: false
,
    init: (element, options) ->
        self = @
        console.log 'initing layout'