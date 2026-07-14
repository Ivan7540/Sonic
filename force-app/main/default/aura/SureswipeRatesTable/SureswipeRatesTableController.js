({
	doInit : function(cmp, event, helper) {
		cmp.set('v.ratesColumns', [
            {label: 'Product', 		fieldName: 'productName',	type: 'text'},
            {label: 'Original Rate', fieldName: 'currentRate', 	type: 'percent', typeAttributes: { 
                    step: '0.00001',
                    minimumFractionDigits: '2',
                    maximumFractionDigits: '3'
                }
            },
            {label: 'Amended Rate',     fieldName: 'newRate', 	    type: 'percent', typeAttributes: { 
                    step: '0.00001',
                    minimumFractionDigits: '2',
                    maximumFractionDigits: '3'
                }
            }
        ]);
        if(cmp.get("v.sObjectName") == 'Opportunity'){
            cmp.set("v.title", "Quote Rates");
        }else if(cmp.get("v.sObjectName")== 'Account'){
            cmp.set("v.title", "Contract Rates");
        }
        helper.doInit(cmp, event);
	}
})