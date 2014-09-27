steal( 'can/', 'js/plugins/underscore', function (can, _) {
        return can.Map.extend({
            modules: [],

            initModule: function (module, id) {
                var self = this;

                if ( ! self.checkModule(id)) {
                    steal(module.path, function (Module) {
                        if (Module) {
                            self.addModule(id);
                            console.log('wtf')
                            new Module('#' + id);
                            self.activateModule(id);
                        } else {
                            if (module.path) {
                                throw new Error('Please check constructor of ' + module.path + '.js');
                            } else {
                                throw new Error('Please check existing of module "' + module.name + '"');
                            }
                        }
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
});