$(document).ready(function(){
   var addDiyDom = function(treeId, treeNode) {
      var aObj = $("#" + treeNode.tId + "_a");
      if ($("#diyInput_" + treeNode.tId).length > 0) return;
      var editStr = "<span id='diyBtn_space_" +treeNode.tId+ "' > </span>"
         + "<input data-role='tagsinput' id='diyInput_" + treeNode.tId
         + "' type='text' />";
      aObj.append(editStr);
   };

   var zTreeObj;
   var setting = {
      check: {
         enable: true,
         chkStyle: "checkbox",
         chckboxType: {
            Y: "",
            N: ""
         }
      },
      view: {
         showIcon: false,
         addDiyDom: addDiyDom
      },
      edit: {
         drag: {
            isMove: true
         },
         enable: true
      },
      data: {
         simpleData: {
            enable: true,
            idKey: '_id',
            pIdKey: 'pid'
         },
         key: {
            checked: 'active'
         }
      }
   };

   for(var i = 0, len = nodes.length; i < len; i++) {
      var item = nodes[i];
      if(item.pid) {
         item.pid = item.pid;
      }
      if(!item.pid || item.active) {
         item.open = true;
      }
   }

   zTreeObj = $.fn.zTree.init($("#tree"), setting, nodes);

   $('#addNode').on('click', function() {
      var node = zTreeObj.addNodes(null, {name:"НовыйУзел"}, false);
      zTreeObj.checkNode(node[0], true, false, false);
   });

   checkNode = function(item) {
      var obj = {};

      obj._id = item.id;
      obj.tId = item.tId;
      obj.name = item.name;
      obj.active = item.active;
      parent = item.getParentNode();
      if(parent) {
         obj.parent = parent.id;
         obj.parenttId = parent.tId;
      }

      var result = [obj];
      if(item.children && item.children.length > 0) {
         for(var i = 0, len = item.children.length; i < len; i++) {
            result = result.concat(checkNode(item.children[i]));
         }
      }

      return result;
   };

   $('form.tree').on('submit', function(ev) {
      ev.preventDefault();

      var nodes = zTreeObj.getNodes(),
          data = [];

      for(var i = 0, len = nodes.length; i < len; i++) {
         data = data.concat(checkNode(nodes[i]));
      }

      $.post('/admin/themes', {items: data}, function(res) {
         alert(res);
      });
   });
});