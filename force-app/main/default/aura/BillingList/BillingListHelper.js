({
    setList : function(component, subscriptions) {
        let totalQuantity = 0;
        let totalUnitPrice = 0;
        let totalTotalPrice = 0;
        for (let i = 0; i < subscriptions.length; i++) {
            totalQuantity += subscriptions[i].SBQQ__Quantity__c;
            totalUnitPrice += subscriptions[i].SBQQ__NetPrice__c;
            totalTotalPrice += subscriptions[i].TotalPrice__c;
        }
        subscriptions.push(
            {Name: 'TOTAL', 
            SBQQ__Quantity__c: totalQuantity, 
            SBQQ__NetPrice__c: totalUnitPrice, 
            TotalPrice__c: totalTotalPrice}
            );
        component.set('v.subscriptionList', subscriptions);
    }
})