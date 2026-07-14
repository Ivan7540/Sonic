public class LCC_SureswipeRatesTableController {
    public class ratesData{
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public Decimal currentRate;
        @AuraEnabled
        public Decimal newRate;
        @AuraEnabled
        public Id quoteLineId;
    }

    @AuraEnabled
    public static List<ratesData> getRates(Id recordId) {
        List<ratesData> rates = new List<ratesData>();
        Map<String, ratesData> ratesRecordMap = new Map<String, ratesData>(); //Map to keep records together
        
        String sObjectName = String.valueOf(recordId.getSObjectType());
        if(sObjectName == 'ProcessInstanceWorkitem'){
            ProcessInstanceWorkitem thisItem = [
                Select Id,
                ProcessInstance.TargetObjectId
                From ProcessInstanceWorkitem
                Where Id = :recordId
            ];
            Id targetId = thisItem.ProcessInstance.TargetObjectId;
            String targetObjectName = String.valueOf(targetId.getSObjectType());
            if(targetObjectName == 'Opportunity'){
                recordId = targetId;
                sObjectName = targetObjectName;
            }
        }
        
        if(sObjectName == 'Opportunity'){
            Opportunity thisOpp = [
                Select Id, 
                AccountId, 
                SBQQ__PrimaryQuote__c 
                From Opportunity 
                Where Id = :recordId
            ];
            List<SBQQ__QuoteLineConsumptionRate__c> consumptionRates = [
                Select Id,
                SBQQ__LowerBound__c,
                SBQQ__UpperBound__c,
                SBQQ__Price__c,
                SBQQ__QuoteLineConsumptionSchedule__c,
                SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c,
                SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c,
                SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c
                From SBQQ__QuoteLineConsumptionRate__c
                Where SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :thisOpp.SBQQ__PrimaryQuote__c
                order by SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c asc
            ];
            
            for(SBQQ__QuoteLineConsumptionRate__c eachRate : consumptionRates){
                String productCode = eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c;
                Decimal quantity = eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c;
                ratesData thisRateData;
                if(ratesRecordMap.containsKey(productCode)){
                    thisRateData = ratesRecordMap.get(productCode);
                }else{
                    thisRateData = new ratesData();
                    thisRateData.quoteLineId = eachRate.Id;
                    thisRateData.productName = eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c;
                    ratesRecordMap.put(productCode, thisRateData);
                    rates.add(thisRateData);
                }
                if(quantity > 0){
                    thisRateData.newRate = eachRate.SBQQ__Price__c/100;
                }else{
                    thisRateData.currentRate = eachRate.SBQQ__Price__c/100;
                }
            }
            if(rates.isEmpty()){//Rates are not on Quote, get it from account, for amendments
                List<SBQQ__SubscriptionConsumptionRate__c> accConsumptionRates = [
                    Select Id,
                    SBQQ__LowerBound__c,
                    SBQQ__UpperBound__c,
                    SBQQ__Price__c,
                    SBQQ__SubscriptionConsumptionSchedule__c,
                    SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c
                    From SBQQ__SubscriptionConsumptionRate__c
                    Where SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Contract__r.AccountId = :thisOpp.AccountId
                    And SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__TerminatedDate__c = null
                    order by SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c asc
                ];
                for(SBQQ__SubscriptionConsumptionRate__c eachRate : accConsumptionRates){
                    ratesData newLine = new ratesData();
                    newLine.quoteLineId = eachRate.Id;
                    newLine.currentRate = eachRate.SBQQ__Price__c/100;
                    newLine.productName = eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c;
                    rates.add(newLine);
                }
            }
        }else if(sObjectName == 'Account'){
            List<SBQQ__SubscriptionConsumptionRate__c> consumptionRates = [
                Select Id,
                SBQQ__LowerBound__c,
                SBQQ__UpperBound__c,
                SBQQ__Price__c,
                SBQQ__SubscriptionConsumptionSchedule__c,
                SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c
                From SBQQ__SubscriptionConsumptionRate__c
                Where SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Contract__r.AccountId = :recordId
                And SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__TerminatedDate__c = null
                order by SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c asc
            ];
            for(SBQQ__SubscriptionConsumptionRate__c eachRate : consumptionRates){
                ratesData newLine = new ratesData();
                newLine.quoteLineId = eachRate.Id;
                newLine.currentRate = eachRate.SBQQ__Price__c/100;
                newLine.productName = eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c;
                rates.add(newLine);
            }
        }
        return rates;
    }
}