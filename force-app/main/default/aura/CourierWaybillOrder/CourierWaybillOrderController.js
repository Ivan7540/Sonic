({
    doInit : function(component, event, helper) {
        component.set('v.columns', [ 
            {label: 'City', fieldName: 'CityName', type: 'text'},
            {label: 'Suburb', fieldName: 'SuburbName', type: 'text'}, 
            {label: 'Postal Code', fieldName: 'BoxCode', type: 'text'}
        ]);        
    },
    findAddress : function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled', true);
        let account_Id = component.get('v.orderObj.AccountId');
        let action = component.get('c.getAddresses');        

        action.setParams({accountId : account_Id});
        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let returnValues = response.getReturnValue();
                component.set('v.addressList', returnValues);
                if(returnValues.length > 0) {
                    button.set('v.disabled', false);
                }
                component.set('v.calledOut', true);                
            } else if (state === "ERROR") {
                let errors = response.getError();
                helper.toastFire('Error!', errors[0].message, 'error');
                console.error(errors);
                button.set('v.disabled', false);
            }
        }));
        $A.enqueueAction(action);
    },
    addressUpdated : function(component, event, helper) {
        component.set('v.calledOut', false);
        let recData = component.find('recordLoader');
        recData.reloadRecord(true);
        let button = component.find('btnAddress'); 
        button.set('v.disabled', false);
    },
    selectionMade : function(component, event, helper) {
        component.set('v.addressSelected', true);
        let button = component.find('btnAddress'); 
        button.set('v.disabled', false);
    },
    requestDelivery : function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled', true);
        let order_Id = component.get('v.orderObj.Id');
        let suburb_Id = component.find('addressTable').getSelectedRows()[0];
        let action = component.get('c.generateWaybillOrder');

        action.setParams({workOrderId : order_Id, suburb : suburb_Id});
        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
                helper.toastFire('Error!', errors[0].message, 'error');
                button.set('v.disabled', false);
            }
        }));
        $A.enqueueAction(action);
    }
})