({
	doInit : function(cmp, event) {
		var action = cmp.get("c.getWorkOrderActions");
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                console.log("test");
                var actionItems = a.getReturnValue();
                var completedStepId = "";
                cmp.set("v.actionItems", actionItems);
                for(var item of actionItems){
                    if(item.Complete__c){
                        completedStepId = item.Id;
                    }
                }
                cmp.set("v.completedStepId", completedStepId);
                console.log("completedStepId", completedStepId);
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
	},
    completeClick : function(cmp, event, helper){
        var action = cmp.get("c.updateCurrentAction");
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Action completed",
                    "type": "success"
                });
                toastEvent.fire();
                helper.doInit(cmp, event);
                $A.get('e.force:refreshView').fire(); 
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": a.getError()[0].message,
                    "type": "error"
                    });
                toastEvent.fire();
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    }
})