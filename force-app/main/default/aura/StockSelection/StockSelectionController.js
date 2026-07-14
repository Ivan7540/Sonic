({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Stock Name', fieldName: 'Name', type: 'text'}, 
            {label: 'Status', fieldName: 'Status', type: 'text'}, 
            {label: 'Serial Number', fieldName: 'SerialNumber', type: 'text'}]);        
    },
    recordUpdate : function(component, event, helper) {
        let warehouse_Id = component.get('v.order.OriginatingWarehouse__c');
        let order_Id = component.get('v.recordId');

        let action = component.get('c.getWarehouseStock');        
        action.setParams({warehouseId : warehouse_Id, orderId : order_Id});
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
    },
    addStock : function(component, event, helper){        
        let selected_Stock = component.find('stockTable').getSelectedRows();
        
        if(selected_Stock.length < 1){
            helper.toastFire('Warning!', 'No Stock selected!', 'warning');
        } else {
            event.getSource().set('v.disabled', true);     
            let order_Id = component.get('v.recordId');
    
            let action = component.get('c.addStockToOrder');
            
            action.setParams({orderId : order_Id, selectedStock : selected_Stock});
            action.setCallback(this, $A.getCallback(function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    event.getSource().set('v.disabled', false);
                    helper.toastFire('Success!', 'Stock added to Order', 'success');
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
        }        
    }
})