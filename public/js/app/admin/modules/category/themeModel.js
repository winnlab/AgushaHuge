import baseModel from 'baseModel'
import can from 'can/'

export default can.Model.extend(
	{
	    id: '_id',
	    resource: baseModel.chooseResource('/theme'),
	    parseModel: baseModel.parseModel,
	    parseModels: baseModel.parseModels
	}, {
		uploaded: baseModel.simpleUploaded,
		removeUploaded: baseModel.simpleRemoveUploaded
	}
);