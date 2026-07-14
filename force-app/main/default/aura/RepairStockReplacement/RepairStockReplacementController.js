({
    doInit : function(component, event, helper) {
        let actions = [{ label: 'Replace Stock', name: 'edit' }];

        component.set('v.columns', [
            {label: 'Serial Number', fieldName: 'Name', type: 'text'},
            {label: 'Model', fieldName: 'Model__c', type: 'text'}, 
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);        
    },
    recordUpdate : function(component, event, helper) {
        helper.refreshList(component);
    },
    handleRowAction: function (component, event, helper) {       
        let row = event.getParam('row');
        component.set('v.lineId', row.Id);
        component.set('v.lineSerial', row.Name);
    },
    handleSuccess : function(component, event, helper) {
        component.set('v.lineId', null);
        component.set('v.lineSerial', null);
        helper.refreshList(component);
    }
})