public class SureswipeMasterpassPricingSection {
    public Decimal debitRate{get;set;}
    public Decimal creditRate{get;set;}
    public Decimal foreignRate{get;set;}
    public Decimal monthlyAmount{get;set;}
    
    public SureswipeMasterpassPricingSection() {
        
        SBQQ__Quote__c[] currentQuoteList = [SELECT Id,
                                             SBQQ__BillingName__c,
                                             SBQQ__Opportunity2__c,
                                             SBQQ__Notes__c,
                                             SBQQ__Account__c
                                             FROM SBQQ__Quote__c 
                                             WHERE Id = :ApexPages.currentPage().getParameters().get('qid')];
        
        system.debug('currentQuoteList: ' + currentQuoteList);
        system.debug('DAL_Product.masterpassFees: ' + DAL_Product.masterpassFees);
        
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
                                                             And SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c IN :DAL_Product.masterpassFees
                                                            ];
            
            system.debug('rates: ' + rates);
            if(rates != null && !rates.isEmpty()) {
                
                for (SBQQ__QuoteLineConsumptionRate__c aRate : rates) {
                    
                    if (aRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.masterpasDebitFee)
                    {
                        this.debitRate = aRate.SBQQ__Price__c;
                    }
                    
                    if (aRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.masterpasCreditFee)
                    {
                        this.creditRate = aRate.SBQQ__Price__c;
                        this.foreignRate = aRate.SBQQ__Price__c;
                    }

                }
                
            } else {
                
                //Throw an Exception to Inform the User
                CustomException ex = new CustomException();
                ex.setMessage('Cannot Find Rates for MasterPass, please run Deal Wizard again');
                throw ex;
                
            }

            List<SBQQ__QuoteLine__c> masterpassLines = [SELECT Id,
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
                                                        And SBQQ__ProductCode__c = :DAL_Product.masterpassRentalPC
                                                        And SBQQ__EffectiveQuantity__c > 0 ];//for amendments
            
            this.monthlyAmount = 0;
            
            system.debug('masterpassLines: ' + masterpassLines);
            if(masterpassLines != null && !masterpassLines.isEmpty()) {
                
                for(SBQQ__QuoteLine__c eachLine : masterpassLines){
                    this.monthlyAmount = (eachLine.SBQQ__NetPrice__c == null? 0:eachLine.SBQQ__NetPrice__c) * eachLine.SBQQ__Quantity__c;
                    system.debug('this.monthlyAmount: ' + this.monthlyAmount);
                }
                
            }

        }
    }
    
    public class CustomException extends Exception {}
}