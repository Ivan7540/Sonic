public class SureswipeAmendmentPricingController {
    public  class lineDetails{
        public String productName{get;set;}
        public String productCode{get;set;}
        public Decimal vatIncludedPrice{get;set;}
        public Decimal quantity{get;set;}
        public Decimal discountPercent{get;set;}
        public Decimal currentRatePercent{get;set;}
        public Decimal newRatePercent{get;set;}
    }
    public class bundlePricing{
        public String RootProductCode{get;set;}
        public String ContractTermString{get;set;}
        public String GroupName{get;set;}
        public Boolean IsOutrightPurchase{get;set;}
        public String InitialSignatories{get;set;}
        public List<lineDetails> lineDetails{get;set;}
        public bundlePricing(){
            this.IsOutrightPurchase = true; //is set to false after line check
            this.lineDetails = new List<lineDetails>();
        }
    }
    public List<lineDetails> rateDetails{get;set;}
    public List<bundlePricing> bundlePricings{get;set;}
    
    private String quoteId;
    public SBQQ__Quote__c currentQuote{get;set;}
    private Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> rootQuoteLinesMap;

    public SureswipeAmendmentPricingController(){
        //Create a list to return
        this.bundlePricings = new List<bundlePricing>();
        
        SBQQ__Quote__c[] currentQuoteList = [
            SELECT Id,
            SBQQ__Opportunity2__c,
            SBQQ__Notes__c,
            SBQQ__Account__c,
            SBQQ__Account__r.Name,
            SBQQ__Account__r.DebtorCode__c,
            SBQQ__PrimaryContact__c,
            SBQQ__PrimaryContact__r.Name,
            SBQQ__PrimaryContact__r.MobilePhone,
            SBQQ__MasterContract__c,
            SBQQ__MasterContract__r.RateContract__c,
            SBQQ__ShippingCity__c,
            SBQQ__ShippingCountry__c,
            SBQQ__ShippingName__c,
            SBQQ__ShippingPostalCode__c,
            SBQQ__ShippingState__c,
            SBQQ__ShippingStreet__c,
            SBQQ__StartDate__c
            FROM SBQQ__Quote__c 
            WHERE Id = :ApexPages.currentPage().getParameters().get('qid')
        ];
        
        if(currentQuoteList.size() > 0){
            currentQuote = currentQuoteList[0];
            this.rateDetails = new List<lineDetails>();
            getNewRates();
            if(this.rateDetails.isEmpty()){
                getExistingRates();
            }
            
            getGroupedLines(currentQuote.Id);
            Map<String, String> contractTermMap = DAL_Product.getContractTermMap();

            String initialersString = '[initial|req|signer0]';
            
            // SECTION FOR PS-704. CH: 2021/08/18
			bundlePricing alternativeBundlePricing = new bundlePricing();
            alternativeBundlePricing.lineDetails = new List<lineDetails>();
            // END SECTION FOR PS-704. CH: 2021/08/18
            
            //loop through root lines
            for(SBQQ__QuoteLine__c eachRootLine : rootQuoteLinesMap.keySet()){
                system.debug('eachRootLine: ' + eachRootLine);
                system.debug('eachRootLine.SBQQ__Group__r.Name: ' + eachRootLine.SBQQ__Group__r.Name);
                system.debug('eachRootLine.SBQQ__ProductName__c: ' + eachRootLine.SBQQ__ProductName__c);
                bundlePricing thisBundlePricing = new bundlePricing();
                thisBundlePricing.GroupName = eachRootLine.SBQQ__Group__r == null? eachRootLine.SBQQ__ProductName__c :  eachRootLine.SBQQ__Group__r.Name;
                thisBundlePricing.InitialSignatories = initialersString;
                thisBundlePricing.RootProductCode = eachRootLine.SBQQ__ProductCode__c;
                thisBundlePricing.ContractTermString = contractTermMap.get(eachRootLine.SBQQ__ProductCode__c);
                thisBundlePricing.lineDetails = new List<lineDetails>();
                for(SBQQ__QuoteLine__c eachChildLine : rootQuoteLinesMap.get(eachRootLine)){
                    if((eachChildLine.SBQQ__EffectiveQuantity__c != 0) && !(eachChildLine.SBQQ__Product__r.SBQQ__Hidden__c)){
                        lineDetails thisLineDetails = new lineDetails();
                        thisLineDetails.productCode = eachChildLine.SBQQ__ProductCode__c;
                        thisLineDetails.discountPercent = eachChildLine.SBQQ__Discount__c;
                        thisLineDetails.productName = eachChildLine.SBQQ__ProductName__c;
                        thisLineDetails.quantity = eachChildLine.SBQQ__EffectiveQuantity__c;
                        thisLineDetails.vatIncludedPrice = eachChildLine.NetTotalWithVATCalc__c;
                        thisBundlePricing.lineDetails.add(thisLineDetails);
                    }
                }
                
                // SECTION FOR PS-704. CH: 2021/08/18
                system.debug('thisBundlePricing: ' + thisBundlePricing);
                
                if(thisBundlePricing.ContractTermString == null){
                    alternativeBundlePricing.GroupName = 'Other Products';
                    alternativeBundlePricing.InitialSignatories = initialersString;
                    alternativeBundlePricing.RootProductCode = eachRootLine.SBQQ__ProductCode__c;
                    alternativeBundlePricing.ContractTermString = 'Other Products';
                    for(SBQQ__QuoteLine__c eachChildLine : rootQuoteLinesMap.get(eachRootLine)){
                        if((eachChildLine.SBQQ__EffectiveQuantity__c != 0) && !(eachChildLine.SBQQ__Product__r.SBQQ__Hidden__c)){
                            lineDetails thisLineDetails = new lineDetails();
                            thisLineDetails.productCode = eachChildLine.SBQQ__ProductCode__c;
                            thisLineDetails.discountPercent = eachChildLine.SBQQ__Discount__c;
                            thisLineDetails.productName = eachChildLine.SBQQ__ProductName__c;
                            thisLineDetails.quantity = eachChildLine.SBQQ__EffectiveQuantity__c;
                            thisLineDetails.vatIncludedPrice = eachChildLine.NetTotalWithVATCalc__c;
                            alternativeBundlePricing.lineDetails.add(thisLineDetails);
                        }
                    }
                } else {
                    this.bundlePricings.add(thisBundlePricing);
                }
            }
            // END SECTION FOR PS-704. CH: 2021/08/18
            // TO REVERT TO PREVIOUS CHANGES, REMOVE THE ABOVE IF/ELSE, AND JUST DO this.bundlePricings.add(thisBundlePricing);
            this.bundlePricings.add(alternativeBundlePricing);
            system.debug('Size: ' + this.bundlePricings.size());
        }
    }

    private void getExistingRates(){
        //Supports only single rates
        List<SBQQ__SubscriptionConsumptionRate__c> rates = [
            Select Id,
            SBQQ__Price__c,
            SBQQ__SubscriptionConsumptionSchedule__c,
            SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__c,
            SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.Name,
            SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode
            From SBQQ__SubscriptionConsumptionRate__c 
            Where SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Contract__c = :currentQuote.SBQQ__MasterContract__r.RateContract__c
            And SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__TerminatedDate__c = null
        ];
        for(SBQQ__SubscriptionConsumptionRate__c eachRate : rates){
            lineDetails thisRateDetail = new lineDetails();
            thisRateDetail.currentRatePercent = eachRate.SBQQ__Price__c;
            thisRateDetail.productCode = eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode;
            thisRateDetail.productName = eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.Name;
            rateDetails.add(thisRateDetail);
        }//End getting rates
    }

    private void getNewRates(){
        //Supports only single rates
        List<SBQQ__QuoteLineConsumptionRate__c> rates = [
            Select Id,
            SBQQ__Price__c,
            SBQQ__QuoteLineConsumptionSchedule__c,
            SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c,
            SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Name,
            SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.ProductCode
            From SBQQ__QuoteLineConsumptionRate__c 
            Where SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :currentQuote.Id
            And SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0
        ];
        for(SBQQ__QuoteLineConsumptionRate__c eachRate : rates){
            lineDetails thisRateDetail = new lineDetails();
            thisRateDetail.newRatePercent = eachRate.SBQQ__Price__c;
            thisRateDetail.productCode = eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.ProductCode;
            thisRateDetail.productName = eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Name;
            rateDetails.add(thisRateDetail);
        }//End getting rates
    }

    private void getGroupedLines(Id quoteId){
        
        SBQQ__QuoteLine__c[] quoteLineList = [
            SELECT Id,
            SBQQ__ProductCode__c,
            SBQQ__ProductName__c,
            SBQQ__Product__r.Family,
            SBQQ__Product__r.SBQQ__Hidden__c,
            SBQQ__Group__r.Name,
            SBQQ__Quantity__c,
            SBQQ__NetPrice__c,
            SBQQ__NetTotal__c,
            SBQQ__RequiredBy__c,
            SBQQ__Discount__c,
            SBQQ__Number__c,
            SBQQ__EffectiveQuantity__c,
            NetTotalWithVATCalc__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Id = :quoteId
            And SBQQ__HasConsumptionSchedule__c = false //no need to show rate products
            order by SBQQ__Number__c asc
        ];

        List<SBQQ__QuoteLine__c> rootQuoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<Id, List<SBQQ__QuoteLine__c>> parentLinesMap = new Map<Id, List<SBQQ__QuoteLine__c>>();

        for(SBQQ__QuoteLine__c eachLine : quoteLineList){
            if(eachLine.SBQQ__RequiredBy__c == null){
                rootQuoteLineList.add(eachLine);
            }else{
                if(parentLinesMap.containsKey(eachLine.SBQQ__RequiredBy__c)){
                    parentLinesMap.get(eachLine.SBQQ__RequiredBy__c).add(eachLine);
                }else{
                    parentLinesMap.put(eachLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>{eachLine});
                }
            }
        }
        this.rootQuoteLinesMap = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();
        //recursively add children
        for(SBQQ__QuoteLine__c eachRootLine : rootQuoteLineList){
            List<SBQQ__QuoteLine__c> childLines = new List<SBQQ__QuoteLine__c>();
            childLines.addAll(getChildLines(eachRootLine, parentLinesMap));
            childLines = reversedLines(childLines);//Reverse lines, they are added from bottom to top
            this.rootQuoteLinesMap.put(eachRootLine, childLines);
        }
    }
    private List<SBQQ__QuoteLine__c> getChildLines(SBQQ__QuoteLine__c thisLine,
                                                    Map<Id, List<SBQQ__QuoteLine__c>> parentLinesMap)
    {
        List<SBQQ__QuoteLine__c> childLines = new List<SBQQ__QuoteLine__c>();
        if(parentLinesMap.containsKey(thisLine.Id)){
            for(SBQQ__QuoteLine__c eachChildLine : parentLinesMap.get(thisLine.Id)){
                childLines.addAll(getChildLines(eachChildLine, parentLinesMap));
            }
        }
        childLines.add(thisLine);
        return childLines;
    }
    private List<SBQQ__QuoteLine__c> reversedLines(List<SBQQ__QuoteLine__c> lines){
        List<SBQQ__QuoteLine__c> reversed = new List<SBQQ__QuoteLine__c>();
        for(Integer i = lines.size() - 1; i >= 0; i--){
            reversed.add(lines[i]);
        }
        return reversed;
    }
}