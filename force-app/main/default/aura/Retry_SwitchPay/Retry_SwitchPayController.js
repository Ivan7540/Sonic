({
    runCallout : function(cmp) {
        let action = cmp.get('c.doCallout');
        action.setParams({AssetProviderId : cmp.get('v.recordId')});
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                //alert('Retried OK: ' + response.getReturnValue());
                $A.get("e.force:closeQuickAction").fire(); // if you want to self-close
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})