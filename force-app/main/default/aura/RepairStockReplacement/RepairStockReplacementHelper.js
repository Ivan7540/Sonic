({
    refreshList : function(component) {
        let workId = component.get('v.workOrder.Id');
        let action = component.get('c.getWorkOrderLines');        
        action.setParams({workOrderId : workId});

        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.lineList', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})