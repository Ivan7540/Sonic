public class LCC_SureswipeSalesProductSelector {
    @AuraEnabled
    public Static List<Deal_Line__c> queryDealItems(Id recordId){
        return [Select Id,
                Deal__c,
                toLabel(Product__c),
                toLabel(Device__c),
                Quantity__c,
                ContractTerm__c,
                DeviceType__c,
                PaymentServer__c,
                PaymentServerQuantity__c,
                BluetoothPrinterQuantity__c,
                MasterpassQuantity__c,
                SwitchpayQuantity__c,
                VAS__c,
                GiftLoyaltyPaymentType__c,
                toLabel(CardDesignType__c),
                AdditionalBrandedCards__c,
                AdditionalEnrolmentForms__c,
                StaticResourceName__c,
                LineDiscount__c
                From Deal_Line__c
                Where Deal__c = :recordId
                And Product__c !=  null
                ];
    }
    @AuraEnabled
    public static void deleteDealLine(Id recordId){
        Deal_Line__c lineToDelete = new Deal_Line__c(Id = recordId);
        delete lineToDelete;
    }
}