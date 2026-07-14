({
    getData : function(cmp, event) {
        var action = cmp.get("c.createTerminalIds");
        action.setParams({
            workOrderId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                cmp.set("v.assetsData", a.getReturnValue());
                console.log(JSON.stringify(a.getReturnValue()));
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    },
    saveData : function(cmp, event, helper){
        var action = cmp.get("c.saveTerminals");
        action.setParams({
            assetsDataString : JSON.stringify(cmp.get("v.assetsData"))
        });
        console.log(cmp.get("v.assetsData"));
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Updated successfully",
                    "type": "success"
                });
                toastEvent.fire();
                helper.getData(cmp, event);
            }else{
                console.log(a.getReturnValue());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    }
})