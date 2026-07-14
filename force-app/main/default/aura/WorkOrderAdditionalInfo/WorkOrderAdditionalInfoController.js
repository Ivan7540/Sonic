({
    recordUpdate : function(component, event, helper) {
        let workOrderDeal = component.get('v.workOrder.Deal__c');

        if(!workOrderDeal){
            let opp_Id = component.get('v.workOrder.Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c');
            let recordId = component.get('v.recordId');

            let action = component.get('c.getDealId');        
            action.setParams({opportunityId : opp_Id, workOrderId : recordId});
            action.setCallback(this, $A.getCallback(function (response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('v.dealId', response.getReturnValue());
                } else if (state === 'ERROR') {
                    let errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
        }        
    }
})