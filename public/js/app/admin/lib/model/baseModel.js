var baseModel = {
    chooseResource: function (resource) {
        return document.location.pathname.indexOf('admin/') !== -1
            ? '/admin' + resource
            : resource;
    },
    parseModel: function (data) {
        return data.data && !data.err ? data.data : data;
    },
    parseModels: function (data) {
        return data.data ? data.data : [];
    },
    simpleUploaded: function (name, value) {
        this.attr(name, value);
    },
    simpleRemoveUploaded: function (name) {
        this.attr(name, undefined);
    }
};

export default baseModel;