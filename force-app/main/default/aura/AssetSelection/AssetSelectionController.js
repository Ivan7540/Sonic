({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Asset Name', fieldName: 'Name', type: 'text'}, 
            {label: 'Status', fieldName: 'Status', type: 'text'}, 
            {label: 'Serial Number', fieldName: 'SerialNumber', type: 'text'}]);

        component.set('v.validate', function() {
           let wolisCreated = component.get("v.wolisCreated");

           if(wolisCreated) {
               // If the component is valid...
               return { isValid: true };
           }
           else {
               // If the component is invalid...
               return { isValid: false, errorMessage: 'Please create Work Order Lines before pressing Next!' };
           }});
    },
    recordUpdate : function(component, event, helper) {
        let accId = component.get('v.workOrder.Account__c');

        let action = component.get('c.getAccountAssets');        
        action.setParams({accountId : accId});
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
    },
    createWorkLines : function(component, event, helper){        
        let selected_Assets = component.find('assetTable').getSelectedRows();
        
        if(selected_Assets.length < 1){
            helper.toastFire('Warning!', 'No Asset selected!', 'warning');
        } else {
            event.getSource().set('v.disabled', true);     
            let workOrder_Id = component.get('v.recordId');
    
            let action = component.get('c.createLineItems');
            
            action.setParams({workOrderId : workOrder_Id, selectedAssets : selected_Assets});
            action.setCallback(this, $A.getCallback(function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    event.getSource().set('v.disabled', false);
                    component.set('v.wolisCreated', true);
                    helper.toastFire('Success!', 'Work Order Lines created', 'success');
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
        }        
    }
})