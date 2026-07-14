({
	doInit : function(cmp, event) {
		var action = cmp.get("c.getMerchantIds");
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                cmp.set("v.merchantIds", a.getReturnValue());
                console.log(JSON.stringify(a.getReturnValue()));
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
	},
    addNewRecord : function(cmp, event){
        var newRecord = JSON.parse(JSON.stringify(cmp.get("v.newMerchantId")));
        var recordList = cmp.get("v.merchantIds");
        recordList.push(newRecord);
        cmp.set("v.merchantIds", recordList);
    },
    editMerchantRecord : function(cmp, event){
        var row = event.getParam('row');
        cmp.set("v.editMerchantId", row.Id);
        cmp.set("v.showEditor", true);
    }
})