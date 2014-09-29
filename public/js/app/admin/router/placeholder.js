import can from 'can/'
import _ from 'js/plugins/underscore/'
export default can.Map.extend({
    modules: [],

    initModule: function (module, id) {
        var self = this;
        if (!self.checkModule(id)) {
            System.import(module.path).then((Module) => {
                if (Module) {
                    self.addModule(id);
                    new Module.default('#' + id);
                    self.activateModule(id);
                } else {
                    msg = module.path
                        ? 'Please check constructor of ' + module.path + '.js'
                        : 'Please check existing of module "' + module.name + '"';

                    throw new Error(msg);
                }
            }).catch((e) => {
                var msg = 'Error caught while executing module ' + module.name
                        + ' from path "' + module.path + '": ';
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