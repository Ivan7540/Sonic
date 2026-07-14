({
    doInit : function(cmp, event, helper) {
        cmp.set('v.tableColumns', [
            {label: 'Product', fieldName: 'productName', type: 'text', hideDefaultActions: true},
            {label: 'Quantity', fieldName: 'quantity', type: 'number', hideDefaultActions: true},
            {label: '% Discount', fieldName: 'discount', type: 'percent', hideDefaultActions: true},
            {label: 'R Discount', fieldName: 'additionalDiscount', type: 'currency', hideDefaultActions: true},
            {label: 'ex VAT', fieldName: 'netAmount', type: 'currency', hideDefaultActions: true},
            // {label: 'VAT', fieldName: 'vatAmount', type: 'currency', hideDefaultActions: true},
            // {label: 'Total', fieldName: 'netTotal', type: 'currency', hideDefaultActions: true},
            {label: 'Qty Rebate', fieldName: 'rebateQty', type: 'number', hideDefaultActions: true},
            {label: 'Rebate Months',fieldName: 'rebateMonths',	type: 'number', hideDefaultActions: true},
            {label: '% Rebate', fieldName: 'rebatePercent', type: 'percent', hideDefaultActions: true},
            {label: 'R Rebate',fieldName: 'rebateAmount', type: 'currency', hideDefaultActions: true}
        ]);
        
        cmp.set('v.ratesColumns', [
            {
              label: 'Product',
              fieldName: 'productName',
              type: 'text'
            },
            {
              label: 'Rate',
              fieldName: 'rate',
              cellAttributes: { alignment: 'left' },
              type: 'percent',
              typeAttributes: {
                step: '0.00001',
                minimumFractionDigits: '2',
                maximumFractionDigits: '3'
              }
            },
            {
              label: 'Transaction Fee',
              fieldName: 'transactionFee',
              cellAttributes: { alignment: 'left' },
              type: 'currency',
              typeAttributes: {
                step: '0.01',
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
              }
           }
        ]);
        
        helper.doInit(cmp, event, helper);
    }
})