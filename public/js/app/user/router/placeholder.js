import can from 'can/'
import _ from 'js/plugins/underscore/'
export default can.Map.extend({
    modules: [],

    initModule: function (module) {
        var self = this;
        if (!self.checkModule(module.id)) {
            System.import(module.path.client).then((Module) => {
                if (Module) {
                    self.addModule(module.id);
                    new Module.default('#' + module.id, module);
                    self.activateModule(module.id);
                } else {
                    msg = module.path.client
                        ? 'Please check constructor of ' + module.path.client + '.js'
                        : 'Please check existing of module "' + module.name + '"';

                    throw new Error(msg);
                }
            }).catch((e) => {
                var msg = 'Error caught while executing module ' + module.name
                        + ' from path "' + module.path.client + '": ';
                console.log(' --- ');
                console.error(msg);
                console.info(e);
                console.info(e.stack);
                console.log(' --- ');
            });
        }
    },

    checkModule: function (id) {
        var module = _.find(this.modules, function(module){
                return module.id === id;
            }),
            exist = !_.isEmpty(module);

        if (exist) {
            this.activateModule(id);
        }
        return exist;
    },

    addModule: function (id) {
        this.modules.push({
            id: id,
            active: false
        });
    },

    activateModule: function (id) {
        can.batch.start();
        _.map(this.modules, function (module) {
            module.attr('active', module.id === id);
        });
        can.batch.stop();
    }

});