({
    doInit : function(component, event, helper) {
        component.set('v.subscriptionColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'}, 
            {label: 'Start Date', fieldName: 'SBQQ__StartDate__c', type: 'date'}, 
            {label: 'End Date', fieldName: 'SBQQ__EndDate__c', type: 'date'}, 
            {label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: 'number'},
            {label: 'Unit Price', fieldName: 'SBQQ__NetPrice__c', type: 'currency'},
            {label: 'Total Price', fieldName: 'TotalPrice__c', type: 'currency'},
            {label: 'Active Rebates', fieldName: 'ActiveRebate__c', type: 'boolean'},
            {label: 'Maximum Rebate End Date', fieldName: 'MaximumRebateEndDate__c', type: 'date'}
        ]);
        component.set('v.rateColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Start Date', fieldName: 'SBQQ__StartDate__c', type: 'date'}, 
            {label: 'End Date', fieldName: 'SBQQ__EndDate__c', type: 'date'}, 
            {label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: 'number'},
            {label: 'Unit Price', fieldName: 'SBQQ__NetPrice__c', type: 'currency'},
            {label: 'Total Price', fieldName: 'TotalPrice__c', type: 'currency'}
        ]);       
    },
    recordUpdate : function(component, event, helper) {
        let conId = component.get('v.recordId');        
        let hasRateContract = component.get('v.contractRecord.RateContract__c') != null;
        
        component.set('v.subscriptionHide', hasRateContract);
        component.set('v.rateHide', !hasRateContract);

        let action = component.get('c.getContractSubscriptions');       
        action.setParams({contractId : conId, isRate : !hasRateContract});   
        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                if(!hasRateContract){  
                    helper.setList(component, response.getReturnValue()); 
                }
                else{
                    component.set('v.subscriptionList', response.getReturnValue());
                }             
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})