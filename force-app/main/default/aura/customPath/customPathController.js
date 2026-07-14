({
    handleSelectOne : function(cmp, event, helper) {
        if(cmp.get("v.allowEdits")){
            var stepName = event.getParam("detail").value;
            var fieldName = "v.recordFields." + cmp.get("v.picklistFieldOne");
            cmp.set(fieldName, stepName);
            
            cmp.find("record").saveRecord($A.getCallback(function(response) {
                if (response.state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Status changed successfully",
                        "type": "success"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }));
        }
    },
    handleSelectTwo : function(cmp, event, helper) {
        if(cmp.get("v.allowEdits")){
            var stepName = event.getParam("detail").value;
            var fieldName = "v.recordFields." + cmp.get("v.picklistFieldTwo");
            cmp.set(fieldName, stepName);
            
            cmp.find("record").saveRecord($A.getCallback(function(response) {
                if (response.state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Status changed successfully",
                        "type": "success"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }));
        }
    }
})