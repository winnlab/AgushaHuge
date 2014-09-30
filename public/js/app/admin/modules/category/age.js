import 'can/'
import Edit from 'edit'

export default Edit.extend({
    defaults: {
        viewpath: 'modules/category/views/',
        viewName: 'setAge.stache',

        moduleName: 'age',

        form: '.setAge',
        
        setRoute: false
    }
}, {});