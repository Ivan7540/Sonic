({
    refreshList : function(component) {
        let accId = component.get('v.workOrder.Account__c');
        let order_Id = component.get('v.workOrder.Order__c');
        let action = component.get('c.getWorkOrderAssets');        
        action.setParams({accountId : accId, orderId : order_Id});

        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.assetList', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})