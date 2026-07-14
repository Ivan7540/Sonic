({
	doInit : function(cmp, event, helper) {
		helper.doInit(cmp, event);
		console.log(cmp.get("v.dealItemId"));
	},
	closeModel: function(cmp, event, helper) {
		cmp.set("v.showEditor", false);
	},
	addNewRecord : function(cmp, event, helper){
		cmp.set("v.dealItemId", "");
		cmp.set("v.showEditor", true);
        helper.doInit(cmp, event);
	},
    editLine : function(cmp, event, helper){
        cmp.set("v.dealItemId", event.getSource().get("v.value"));
        console.log(cmp.get("v.dealItemId"));
        cmp.set("v.showEditor", true);
    },
    deleteLine : function(cmp, event, helper){
        helper.deleteLine(cmp, event);
        console.log(event.getSource().get("v.value"));
        helper.doInit(cmp, event);
    },
    showEditorChange : function(cmp, event, helper){
        if(!cmp.get("v.showEditor")){
            //if it has been set to false, perform doInit as we need to refresh data
            helper.doInit(cmp, event);
        }
    }
})