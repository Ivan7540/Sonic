({
    getStatus : function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled', true);
        let waybillNumber = component.get('v.workOrder.Waybill_Number__c');
        let action = component.get('c.getWaybillStatus');

        action.setParams({waybill : waybillNumber});
        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.shipmentStatus', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
                button.set('v.disabled', false);
            }
        }));
        $A.enqueueAction(action);
    }
})