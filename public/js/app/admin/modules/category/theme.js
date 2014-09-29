import 'can/'
import Edit from 'edit'

export default Edit.extend({
    defaults: {
        viewpath: 'modules/category/views/',
        viewName: 'themeItem.stache',

        moduleName: 'theme',

        successMsg: 'Тема успешно сохранена.',

        form: '.setColor',
        
        setRoute: false
    }
}, {});