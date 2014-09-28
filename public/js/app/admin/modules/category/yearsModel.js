import baseModel from 'baseModel'
import can from 'can/'

export default can.Model.extend({
    id: '_id',
    resource: baseModel.chooseResource('/categoryEncyclopedia/years'),
    parseModel: baseModel.parseModel,
    parseModels: baseModel.parseModels
}, {});