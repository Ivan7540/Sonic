({
    doInit : function(component, event, helper) {
        let actions = [{ label: 'Assign', name: 'edit' }];

        component.set('v.columns', [
            {label: 'Asset Name', fieldName: 'Name', type: 'text'}, 
            {label: 'Serial Number', fieldName: 'SerialNumber', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);        
    },
    recordUpdate : function(component, event, helper) {
        helper.refreshList(component);
    },
    handleRowAction: function (component, event, helper) {       
        let row = event.getParam('row');
        let recId = row.Id;
        component.set('v.assetId', recId);
    },
    handleSuccess : function(component, event, helper) {
        component.set('v.assetId', null);
        helper.refreshList(component);
    }
})