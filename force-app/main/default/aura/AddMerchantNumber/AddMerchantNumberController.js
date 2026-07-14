({
	doInit : function(cmp, event, helper) {
		var actions = [
            {label: 'Edit', name: 'edit'},
        ];
		cmp.set('v.columns', [
            {label: 'Merchant Number', fieldName: 'Name', type: 'text', typeAttributes: { required: true }},
            //{label: 'MCC Code', fieldName: 'mccCode__c', type: 'text'},
            {label: 'Type', fieldName: 'Type__c', type: 'picklist', typeAttributes: { required: true } },
			{label: 'Description', fieldName: 'Description__c', type: 'text'},
            {label: 'Product Family', fieldName: 'Product_Family__c', type: 'picklist'},
            {label: 'Acquiring  Bank', fieldName: 'AcquiringBank__c', type: 'picklist', typeAttributes: { required: true }},
			{type: 'action', typeAttributes: { rowActions: actions } }
        ]);
		helper.doInit(cmp, event);
	},
	addNewRecord : function(cmp, event, helper){
		cmp.set("v.editMerchantId", "");
		cmp.set("v.showEditor", true);
	},
	handleRowAction : function(cmp, event, helper){
		var action = event.getParam('action');
        switch (action.name) {
            case 'edit':
                helper.editMerchantRecord(cmp, event);
				helper.doInit(cmp, event);
                break;           
        }
	},
	closeModel: function(cmp, event, helper) {
		cmp.set("v.showEditor", false);
	 },
	 recordFormSuccess : function(cmp, event, helper){
		 cmp.set("v.showEditor", false);
		 helper.doInit(cmp, event);
	 }
})