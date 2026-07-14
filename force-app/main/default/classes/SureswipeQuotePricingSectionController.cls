/**
* Author	:	Swapnil Walse
* Date		:	05 May 2021
* Desc		:	controller for the pricing section
* 			:	
* 			:	 
* 				
**/
public class SureswipeQuotePricingSectionController 
{
    public class bundlePricing
    {
        public String RootProductCode {get;set;}
        public String ContractTermString {get;set;}
        public String GroupName {get;set;}
        public Boolean IsOutrightPurchase {get;set;}
        public Integer DeviceQty {get;set;}
        public Decimal DeviceTotalPrice {get;set;}
        public Decimal DeviceTotalPriceInclVAT {get;set;}
        public Decimal CalloutFee {get;set;}
        public Map<String, Integer> productQtyMap {get;set;}
        public Map<String, Decimal> productPriceMap {get;set;}
        public String productKeySet {get;set;}
        public String InitialSignatories {get;set;}

        public bundlePricing()
        {
            this.IsOutrightPurchase = true;
            this.DeviceQty = 0;
            this.DeviceTotalPrice = 0;
            this.DeviceTotalPriceInclVAT = 0;
            this.CalloutFee = 0;
            this.productQtyMap = new Map<String, Integer>();
            this.productPriceMap = new Map<String, Decimal>();
        }
    }

    public List<bundlePricing> bundlePricings {get;set;}
    
    private String quoteId;
    public SBQQ__Quote__c currentQuote{get;set;}
    private SBQQ__QuoteLine__c[] rootQuoteLineList;
    private Deal__c currentDeal {get; set;}
    
    private Decimal domesticDebitCardRate;
    private Decimal domesticCreditCardRate;
    private Decimal internationalDebitCardRate;
    private Decimal internationalCreditCardRate;
    private Decimal amexRate;

    public SureswipeQuotePricingSectionController()
    {
        //Create a list to return
        this.bundlePricings = new List<bundlePricing>();        
        currentQuote = queryQuote(ApexPages.currentPage().getParameters().get('qid'));        
        //NOTE: below query will only return immediate childrent, and not all sub lines.
        rootQuoteLineList = getQuoteLines();
        setDeal();
        //Supports only single rates
        setRates();
        
        Map<String, String> contractTermMap = DAL_Product.getContractTermMap();
        MAP<String, String> calloutFeeProductCodeMap = DAL_Product.getCalloutFeeProductCodeMap();
        List<PriceBookEntry> calloutFeeProductPBEs = getEntries(DAL_Product.calloutFeeProductCodes, DAL_Product.SSPriceBookName);
        Map<String, Decimal> calloutFeeMap = new Map<String, Decimal>();

        for(PriceBookEntry eachPBE : calloutFeeProductPBEs)
        {
            calloutFeeMap.put(eachPBE.ProductCode, eachPBE.UnitPrice);
        }

        //get list of signatories for initials
        SignatureController sigController = new SignatureController();
        sigController.getContactRelations(currentQuote.SBQQ__Account__c);
        List<String> initialers = sigController.getInitialSignatories();
        String initialersString = String.join(initialers,' ');
        
        //loop through root lines
        for(SBQQ__QuoteLine__c eachParentLine : rootQuoteLineList)
        {
            if(contractTermMap.containsKey(eachParentLine.SBQQ__ProductCode__c))
            {
                bundlePricing thisBundlePricing = new bundlePricing();
                List<SBQQ__QuoteLine__c> childLines = eachParentLine.SBQQ__Quote_Lines__r;
                
                for(Integer i = 0; i < childLines.size(); i++)
                {
                    SBQQ__QuoteLine__c eachChildLine = childLines[i];
                    //This caters for outright purchases, as pricing will be on device line
                    //else it will be 0 anyways
                    if(eachChildLine.SBQQ__Product__r.Family == 'Device')
                    {
                        thisBundlePricing.DeviceQty++;
                        thisBundlePricing.DeviceTotalPrice = thisBundlePricing.DeviceTotalPrice + (eachChildLine.SBQQ__NetPrice__c == null? 0: eachChildLine.SBQQ__NetPrice__c);
                        thisBundlePricing.DeviceTotalPriceInclVAT = thisBundlePricing.DeviceTotalPriceInclVAT + (eachChildLine.NetTotalWithVATCalc__c == null? 0: eachChildLine.NetTotalWithVATCalc__c);
                    }
                    //This caters for Rental device
                    if(eachChildLine.SBQQ__ProductCode__c == DAL_Product.deviceRentalProductCode || eachChildLine.SBQQ__Product__r.Family == 'Rental')
                    {
                        thisBundlePricing.DeviceQty++;
                        thisBundlePricing.DeviceTotalPrice = thisBundlePricing.DeviceTotalPrice + (eachChildLine.SBQQ__NetPrice__c == null? 0: eachChildLine.SBQQ__NetPrice__c) * eachChildLine.SBQQ__Quantity__c;
                        thisBundlePricing.DeviceTotalPriceInclVAT = thisBundlePricing.DeviceTotalPriceInclVAT + (eachChildLine.NetTotalWithVATCalc__c == null? 0: eachChildLine.NetTotalWithVATCalc__c);
                        thisBundlePricing.IsOutrightPurchase = false;
                    }
                    //Add rest of products to Maps
                    if(thisBundlePricing.productQtyMap.containsKey(eachChildLine.SBQQ__ProductCode__c))
                    {
                        Integer currentValue = thisBundlePricing.productQtyMap.get(eachChildLine.SBQQ__ProductCode__c);
                        currentValue += Integer.valueOf(eachChildline.SBQQ__Quantity__c);
                        thisBundlePricing.productQtyMap.put(eachChildLine.SBQQ__ProductCode__c, currentValue);
                    }
                    else
                    {
                        thisBundlePricing.productQtyMap.put(eachChildLine.SBQQ__ProductCode__c, Integer.valueOf(eachChildLine.SBQQ__Quantity__c));
                    }

                    if(thisBundlePricing.productPriceMap.containsKey(eachChildLine.SBQQ__ProductCode__c))
                    {
                        Decimal currentValue = thisBundlePricing.productPriceMap.get(eachChildLine.SBQQ__ProductCode__c);
                        currentValue += (eachChildline.SBQQ__NetTotal__c == null? 0: eachChildline.SBQQ__NetTotal__c);
                        thisBundlePricing.productPriceMap.put(eachChildLine.SBQQ__ProductCode__c, currentValue);
                    }
                    else
                    {
                        thisBundlePricing.productPriceMap.put(eachChildLine.SBQQ__ProductCode__c, (eachChildline.SBQQ__NetTotal__c == null? 0: eachChildline.SBQQ__NetTotal__c));
                    }

                    //Cater for G&L bundles
                    if((eachChildLine.SBQQ__ProductCode__c == 'SS_LOYALTY_AND_GIFT_BUNDLE') ||(eachChildLine.SBQQ__ProductCode__c == 'SS_LOYALTY_AND_GIFT_3_BUNDLE')
                            ||(eachChildLine.SBQQ__ProductCode__c == 'SS_LOYALTY_AND_GIFT_4_BUNDLE'))
                    {
                        childLines.addAll(getGLLines());
                    }
                }
                
                thisBundlePricing.productKeySet = String.join(new List<String>(thisBundlePricing.productQtyMap.keySet()), ',');
                thisBundlePricing.GroupName = eachParentLine.SBQQ__Group__r?.Name;
                thisBundlePricing.ContractTermString = contractTermMap.get(eachParentLine.SBQQ__ProductCode__c);

                if(calloutFeeProductCodeMap.get(eachParentLine.SBQQ__ProductCode__c) != 'INCLUDED')
                {
                    thisBundlePricing.CalloutFee = calloutFeeMap.get(calloutFeeProductCodeMap.get(eachParentLine.SBQQ__ProductCode__c));
                }

                thisBundlePricing.InitialSignatories = initialersString;
                this.bundlePricings.add(thisBundlePricing);
            }
        }        
    }
    
    public SBQQ__Quote__c getQuote()
    {
        return currentQuote;
    }
    
    public Decimal getDomesticDebitCardRate()
    {
        return domesticDebitCardRate;
    }

    public Decimal getDomesticCreditCardRate()
    {
        return domesticCreditCardRate;
    }

    public Decimal getInternationalDebitCardRate()
    {
        return internationalDebitCardRate;
    }

    public Decimal getInternationalCreditCardRate()
    {
        return internationalCreditCardRate;
    }
    public Decimal getAmexRate()
    {
        return amexRate;
    }

    public Decimal getReactivationFee()
    {
        PriceBookEntry pbe = getEntry(DAL_Product.reactivationFeeProductCode, DAL_Product.SSPriceBookName);
        return pbe.UnitPrice;
    }

    public Decimal getUnpaidDebitOrderFee()
    {
        PriceBookEntry pbe = getEntry(DAL_Product.unpaidDeibtOrderProductCode,DAL_Product.SSPriceBookName);
        return pbe.UnitPrice;
    }

    public Decimal getPaperRollDeliveryFee()
    {
        PriceBookEntry pbe = getEntry(DAL_Product.paperRollDeliverProductCode, DAL_Product.SSPriceBookName);
        return pbe.UnitPrice;
    }
    
	public Decimal getPaperRollFee()
    {
        PriceBookEntry pbe = getEntry(DAL_Product.paperRollProductCode, DAL_Product.SSPriceBookName);
        return pbe.UnitPrice;
    }
    
    public Decimal getMonthlyConnectivityFee()
    {
        PriceBookEntry pbe = getEntry(DAL_Product.monthlyConnectivityFee, DAL_Product.SSPriceBookName);
        return pbe.UnitPrice;
    }
    
    //Same for all bundles in the quote
    public Decimal getSwipeValue()
    {
        if(currentDeal != null)
        {
            return currentDeal.SwipeValue__c;
        }
        else
        {
            return [Select Id, Monthly_Swipe_Value_Card_Value__c From Account Where Id = :currentQuote.SBQQ__Account__c].Monthly_Swipe_Value_Card_Value__c;
        }
    }

    private void setRates()
    {
        List<SBQQ__QuoteLineConsumptionRate__c> rates = 
        [
            SELECT  Id,
                    SBQQ__Price__c,
                    SBQQ__QuoteLineConsumptionSchedule__c,
                    SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__c,
                    SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Name,
                    SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c
            FROM SBQQ__QuoteLineConsumptionRate__c 
            WHERE SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :currentQuote.Id
        ];
    
        if(rates.isEmpty())
        {
            //Rates are not on Quote, get it from account, for amendments
            List<SBQQ__SubscriptionConsumptionRate__c> accConsumptionRates = [
                SELECT  Id,
                        SBQQ__LowerBound__c,
                        SBQQ__UpperBound__c,
                        SBQQ__Price__c,
                        SBQQ__SubscriptionConsumptionSchedule__c,
                        SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c,
                        SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode
                FROM SBQQ__SubscriptionConsumptionRate__c
                WHERE SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Contract__r.AccountId = :currentQuote.SBQQ__Account__c
                AND SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__TerminatedDate__c = null
                ORDER BY SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__ProductName__c asc
            ];

            for(SBQQ__SubscriptionConsumptionRate__c eachRate : accConsumptionRates)
            {
                if(eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode == DAL_Product.domesticCreditCardFees)
                {
                    domesticCreditCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode == DAL_Product.domesticDebitCardFees)
                {
                    domesticDebitCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode == DAL_Product.internationalCreditCardFees)
                {
                    internationalCreditCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode == DAL_Product.internationalDebitCardFees)
                {
                    internationalDebitCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode == DAL_Product.amexCardFee)
                {
                    amexRate = eachRate.SBQQ__Price__c;
                }
            }
        }
        else 
        {
            for(SBQQ__QuoteLineConsumptionRate__c eachRate : rates)
            {
                if(eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.domesticCreditCardFees)
                {
                    domesticCreditCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.domesticDebitCardFees)
                {
                    domesticDebitCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.internationalCreditCardFees)
                {
                    internationalCreditCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.internationalDebitCardFees)
                {
                    internationalDebitCardRate = eachRate.SBQQ__Price__c;
                }
                if(eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c == DAL_Product.amexCardFee)
                {
                    amexRate = eachRate.SBQQ__Price__c;
                }
            }
        }        
    }

    private void setDeal()
    {
        if(currentQuote != null && currentQuote.SBQQ__Opportunity2__c != null)
        {
           List<Deal__c> deals = 
            [
                SELECT  Id,
                        SwipeValue__c
                FROM Deal__c
                WHERE Opportunity__c = :currentQuote.SBQQ__Opportunity2__c
            ];

            if(!deals.isEmpty())
            {
                currentDeal = deals[0];
            }
            else
            {
                currentDeal = null;
            } 
        }        
    }

    private SBQQ__Quote__c queryQuote(String quoteId)
    {
        return
        [
            SELECT  Id,
                    Name,
                    SBQQ__BillingName__c,
                    SBQQ__Opportunity2__c,
                    SBQQ__Notes__c,
                    SBQQ__Account__c,
                    SBQQ__MasterContract__c
            FROM SBQQ__Quote__c 
            WHERE Id = :quoteId
            LIMIT 1
        ];
    }

    private List<SBQQ__QuoteLine__c> getQuoteLines()
    {
        return
        [
            SELECT  Id,
                    SBQQ__ProductCode__c,
                    SBQQ__Product__r.Name,
                    SBQQ__Product__r.Family,
                    SBQQ__Group__r.Name,
                    SBQQ__Quantity__c,
                    SBQQ__NetPrice__c,
                    SBQQ__NetTotal__c,
                    NetTotalWithVATCalc__c,
                    SBQQ__RequiredBy__c,
                    (
                        SELECT  Id,
                                SBQQ__ProductCode__c,
                                SBQQ__Product__r.Name,
                                SBQQ__Product__r.Family,
                                SBQQ__Group__r.Name,
                                SBQQ__Quantity__c,
                                SBQQ__NetPrice__c,
                                SBQQ__NetTotal__c,
                                NetTotalWithVATCalc__c,
                                SBQQ__RequiredBy__c
                        FROM SBQQ__Quote_Lines__r
                    )
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Id = :currentQuote.id
            AND SBQQ__RequiredBy__c = null
        ];
    }

    private List<SBQQ__QuoteLine__c> getGLLines()
    {
        return
        [
            SELECT  Id,
                    SBQQ__ProductCode__c,
                    SBQQ__Product__r.Name,
                    SBQQ__Product__r.Family,
                    SBQQ__Group__r.Name,
                    SBQQ__Quantity__c,
                    SBQQ__NetPrice__c,
                    SBQQ__NetTotal__c,
                    NetTotalWithVATCalc__c,
                    SBQQ__RequiredBy__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :currentQuote.Id
            AND SBQQ__RequiredBy__r.SBQQ__ProductCode__c IN ('SS_LOYALTY_AND_GIFT_BUNDLE', 'SS_LOYALTY_AND_GIFT_3_BUNDLE', 'SS_LOYALTY_AND_GIFT_4_BUNDLE')
        ];
    }

    private PriceBookEntry getEntry(String productCode, String pricebookName)
    {
        List<PriceBookEntry> result = getEntries(new List<String>{productCode}, pricebookName);

        if(result.size() == 1)
        {
            return result[0];
        }
        else
        {
            return null;
        }        
    }

    private List<PriceBookEntry> getEntries(List<String> productCodes, String pricebookName)
    {
        return
        [
            SELECT  Id,
                    UnitPrice,
                    ProductCode
            FROM PriceBookEntry
            WHERE ProductCode = :productCodes
            AND PriceBook2.Name = :pricebookName
            AND isActive = true
        ];
    }
}