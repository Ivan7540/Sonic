public with sharing class SureswipeSwitchpayPricingSection {
    public Decimal laybyDisbursementCommission{get;set;}
    public Decimal nonLaybyDisbursementCommission{get;set;}
    public Decimal loanApplicationSubFee{get;set;}
    public Decimal laybyApplicationSubFee{get;set;}
    
    public SureswipeSwitchpayPricingSection() {
        SBQQ__Quote__c[] currentQuoteList = [SELECT Id,
                                             SBQQ__BillingName__c,
                                             SBQQ__Opportunity2__c,
                                             SBQQ__Notes__c,
                                             SBQQ__Account__c
                                             FROM SBQQ__Quote__c 
                                             WHERE Id = :ApexPages.currentPage().getParameters().get('qid')];
        
        if(currentQuoteList != null && !currentQuoteList.isEmpty()){
            
            SBQQ__Quote__c currentQuote = currentQuoteList[0];
            //Supports only single rates
            List<SBQQ__QuoteLineConsumptionRate__c> rates = [Select Id,
                                                             SBQQ__Price__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Name,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c
                                                             From SBQQ__QuoteLineConsumptionRate__c 
                                                             Where SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :currentQuote.Id
                                                             And SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c = :DAL_Product.switchpayFees
                                                            ];
            
            system.debug('rates: ' + rates);
            if(rates != null && !rates.isEmpty()) {
                
                this.laybyDisbursementCommission = rates[0].SBQQ__Price__c;
                this.nonLaybyDisbursementCommission = rates[0].SBQQ__Price__c;
                
            }
            
            List<SBQQ__QuoteLine__c> switchpayLines = [SELECT Id,
                                                       SBQQ__ProductCode__c,
                                                       SBQQ__Product__r.Name,
                                                       SBQQ__Product__r.Family,
                                                       SBQQ__Group__r.Name,
                                                       SBQQ__Quantity__c,
                                                       SBQQ__NetPrice__c,
                                                       SBQQ__NetTotal__c,
                                                       SBQQ__RequiredBy__c
                                                       FROM SBQQ__QuoteLine__c
                                                       WHERE SBQQ__Quote__r.Id = :currentQuote.Id
                                                       And SBQQ__ProductCode__c = :DAL_Product.switchpayRentalPC
                                                       And SBQQ__EffectiveQuantity__c > 0];//for amendments
            this.loanApplicationSubFee = 0;
            this.laybyApplicationSubFee = 0;
            
            if(switchpayLines != null && !switchpayLines.isEmpty()) {
                
                for(SBQQ__QuoteLine__c eachLine : switchpayLines){
                    this.loanApplicationSubFee = (eachLine.SBQQ__NetPrice__c == null? 0:eachLine.SBQQ__NetPrice__c) * eachLine.SBQQ__Quantity__c;
                    this.laybyApplicationSubFee = (eachLine.SBQQ__NetPrice__c == null? 0:eachLine.SBQQ__NetPrice__c) * eachLine.SBQQ__Quantity__c;
                }
            }
        }
    }
    
    public class CustomException extends Exception {}
}