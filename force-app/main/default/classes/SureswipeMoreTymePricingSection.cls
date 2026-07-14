public with sharing class SureswipeMoreTymePricingSection {
    public Decimal bankFees {get;set;}
    public Decimal transactionFees {get;set;}
    
    public SureswipeMoreTymePricingSection(){
        this.bankFees = 0;
        this.transactionFees = 0;
        
        SBQQ__Quote__c[] currentQuoteList = [SELECT Id,
                                             SBQQ__BillingName__c,
                                             SBQQ__Opportunity2__c,
                                             SBQQ__Notes__c,
                                             SBQQ__Account__c
                                             FROM SBQQ__Quote__c 
                                             WHERE Id = :ApexPages.currentPage().getParameters().get('qid')];
        
        system.debug('currentQuoteList: ' + currentQuoteList);
        //system.debug('DAL_Product.masterpassFees: ' + DAL_Product.masterpassFees);
        
        if(currentQuoteList.size() > 0){
            SBQQ__Quote__c currentQuote = currentQuoteList[0];
            //Supports only single rates
            List<SBQQ__QuoteLineConsumptionRate__c> bankRates = [Select Id,
                                                             SBQQ__Price__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Name,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c
                                                             From SBQQ__QuoteLineConsumptionRate__c 
                                                             Where SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :currentQuote.Id
                                                             And SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c = :DAL_Product.moreTymeBankFee
                                                            ];
            
            if(bankRates.size() > 0){
                system.debug('bank rates: ' + bankRates);
             	this.bankFees = bankRates[0].SBQQ__Price__c;   
            } else {
                this.bankFees = 0;
            }
            
			//Supports only single rates
            List<SBQQ__QuoteLineConsumptionRate__c> transactionRates = [Select Id,
                                                             SBQQ__Price__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Name,
                                                             SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c
                                                             From SBQQ__QuoteLineConsumptionRate__c 
                                                             Where SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :currentQuote.Id
                                                             And SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c = :DAL_Product.moreTymeTransactionFee
                                                            ];
            
            if(transactionRates.size() > 0){
                system.debug('transactionRates: ' + transactionRates);
                this.transactionFees = transactionRates[0].SBQQ__Price__c;   
            } else {
                this.transactionFees = 0;
            }
        }
    }
}