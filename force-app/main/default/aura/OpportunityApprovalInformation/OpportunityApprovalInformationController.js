/**
 * Created by JurgitaG on 7/19/2021.
 */

({
    doInit : function(cmp, event, helper){
            cmp.set('v.productColumns', [
                        {label: 'Product', 		fieldName: 'productName',	type: 'text'},
                        {label: 'Discount', 	fieldName: 'discount',	type: 'percent'},
                        {label: 'Prior Quantity', 		fieldName: 'priorQuantity',	type: 'number'},
                        {label: 'Quantity', 		fieldName: 'quantity',	type: 'number'},
                        {label: 'Net Total', fieldName: 'netTotal', 	type: 'currency'},
                    ]);

                    helper.getOpportunityType(cmp, event);
                    helper.getOpportunityLines(cmp, event);
        },
});