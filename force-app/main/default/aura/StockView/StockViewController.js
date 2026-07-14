({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Stock Name', fieldName: 'Name', type: 'text'}, 
            {label: 'Serial Number', fieldName: 'Serial_Number__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
        ]);        
    },
    recordUpdate : function(component, event, helper) {
        let accId = component.get('v.workOrder.Account__c');
        let action = component.get('c.getAccountStock');        
        action.setParams({accountId : accId});

        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.stockList', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})