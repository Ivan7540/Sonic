/****************************************		
 Created By : Kumar
 Date : 16/02/2022
 Description: Created for Payment Link Integration.
 	The below method prepares the request messages and pass on to the Flowgear to make a callout to the Adumo's payment link API endpoint. 	
****************************************/
public without sharing class SendPaymentLink {
    
   public class responseParam{
        @InvocableVariable public Integer statusCode;
        @InvocableVariable public String messageBody;
    }
    
    @InvocableMethod(label='Send Payment Link' description='Send Payment Link' category='Deal')
    public static List<responseParam> sendPaymentLink(List<String> inputs) {
        
        List<responseParam> outputs = new List<responseParam>();        
        for(String recordId : inputs){
            HttpResponse response = invokeAPI(recordId);
            responseParam output = new responseParam();
            output.statusCode = response.getStatusCode();
            output.messageBody = response.getBody(); 
            outputs.add(output);
        }
        return outputs;
    }
    public static HttpResponse invokeAPI(String recordId){
        
        Map<String, String> inputMap = initializeInputMap(recordId);
        
        SendPaymentLinkData oApiData = new SendPaymentLinkData();
        oApiData.expiryDate = DateUtil.formatDate(date.today().addDays(3), 'yyyy-MM-dd');
        oApiData.customerName = inputMap.get('customerName'); //Account Name/Trading Name
        oApiData.customerEmail = inputMap.get('customerEmail');// Lead Email
        oApiData.specialNotes = inputMap.get('specialNotes');
        //oApiData.msisdn = 'Test';
        //oApiData.uci = 'Test';
        //oApiData.puid = 'Test';
        oApiData.merchantReference = inputMap.get('merchantReference');
        oApiData.amount = Double.valueOf(inputMap.get('amount')); //  sum of deal lines for outright purchase
        oApiData.schedule = new SendPaymentLinkData.schedule();
        oApiData.schedule.startDate = DateUtil.formatDate(date.today(), 'yyyy-MM-dd');
        oApiData.schedule.frequency = 6;        
        oApiData.schedule.recurrence = 1;
        oApiData.paymentLinkChannels = new List<String>();
        oApiData.paymentLinkChannels.add('EMAIL');
        oApiData.description = inputMap.get('description'); // list of products on deal lines for outright purchase and quantity
        oApiData.messageBody = inputMap.get('messageBody');       
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpResp = new HttpResponse();
        httpReq.setEndpoint('callout:Flowgear/paymentlink/production/send/');        
        httpReq.setHeader('Content-Type','application/json');           
        httpReq.setMethod('POST'); 
        httpReq.setBody(JSON.serialize(oApiData));
        System.debug('HttpRequest ' + httpReq);
        httpResp = http.send(httpReq);
        System.debug(httpResp);
        return httpResp;
    }
    public static Map<String,String> initializeInputMap(String dealId){
        
        String 	productName;
        String 	primaryQuoteId;
        String 	description = '';
        String 	specialNotes = '';
        Integer quantity = 0;
        Double  totalAmount = 0;
        Double	unitPrice = 0;
        Double	totalOnceoffAmount = 0;
        Double	totalDiscountAmount = 0;
        Integer  monthlyAmount = 0;
        
        Map<String,String> inputMap = new Map<String,String>();
        List<Deal__c> dealList = [SELECT Id,Deal_Number__c,Lead__r.Email,Account__r.Name,Opportunity__r.SBQQ__PrimaryQuote__c From Deal__c Where Id =: dealId];
        
        For(Deal__c aDeal : dealList){
            inputMap.put('merchantReference', aDeal.Deal_Number__c);
            inputMap.put('customerName', aDeal.Account__r.Name);
            inputMap.put('customerEmail', aDeal.Lead__r.Email);
            primaryQuoteId  = aDeal.Opportunity__r.SBQQ__PrimaryQuote__c;
        }
        
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id,SBQQ__Quantity__c,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__NetTotal__c,SBQQ__RegularPrice__c,SBQQ__TotalDiscountAmount__c,SBQQ__Product__r.IsSubscriptionProduct__c,NetTotalWithVATCalc__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Group__r.Name LIKE '%Outright Purchase%' AND NetTotalWithVATCalc__c > 0 AND SBQQ__Quote__c =: primaryQuoteId];
        List<SBQQ__QuoteLine__c> quoteLinesOnceoff = new List<SBQQ__QuoteLine__c>(); 
        List<SBQQ__QuoteLine__c> quoteLinesMonthly = new List<SBQQ__QuoteLine__c>();
        Set<String> setOnceOffProductCodes = new Set<String>();
        
        For(SBQQ__QuoteLine__c aQuoteLine : quoteLines){
            if(aQuoteLine.SBQQ__Product__r.IsSubscriptionProduct__c){
                quoteLinesMonthly.add(aQuoteLine);    
            }else{
                quoteLinesOnceoff.add(aQuoteLine);
            }    
        }
        // total once off amount
        For(SBQQ__QuoteLine__c aQuoteLine : quoteLinesOnceoff){
            totalAmount = totalAmount + aQuoteLine.NetTotalWithVATCalc__c;
            setOnceOffProductCodes.add(aQuoteLine.SBQQ__ProductCode__c);
        }        
        // total monthly amount
        For(SBQQ__QuoteLine__c aQuoteLine : quoteLinesMonthly){
            monthlyAmount = monthlyAmount + Integer.valueof(aQuoteLine.NetTotalWithVATCalc__c);
        }
        
        //System.debug('setOnceOffProductCodes->'+setOnceOffProductCodes);
        
        for (String productCode : setOnceOffProductCodes) {
            unitPrice = 0;
            totalOnceoffAmount = 0;
            totalDiscountAmount = 0;
            for(Integer j = 0; j < quoteLinesOnceoff.size(); j++){
                if(productCode == quoteLinesOnceoff.get(j).SBQQ__ProductCode__c){
                    quantity = quantity + integer.valueOf(quoteLinesOnceoff.get(j).SBQQ__Quantity__c);
                    productName = quoteLinesOnceoff.get(j).SBQQ__ProductName__c;
                    unitPrice = quoteLinesOnceoff.get(j).SBQQ__RegularPrice__c;
                    totalOnceoffAmount = totalOnceoffAmount + quoteLinesOnceoff.get(j).NetTotalWithVATCalc__c;
                    totalDiscountAmount = totalDiscountAmount + quoteLinesOnceoff.get(j).SBQQ__TotalDiscountAmount__c;
                }
            }
            if(description == ''){
                description = quantity + ' x ' + productName + ' @ ' + 'ZAR ' + ((Decimal)unitPrice).setScale(2) + ' LESS '  + 'ZAR '+ ((Decimal)totalDiscountAmount).setScale(2) + ' Discount : ' + 'ZAR ' + ((Decimal)totalOnceoffAmount).setScale(2);    
            }else{
                description = description + ' , ' + quantity + ' x ' + productName + ' @ ' + 'ZAR ' + ((Decimal)unitPrice).setScale(2) + ' LESS '  + 'ZAR '+ ((Decimal)totalDiscountAmount).setScale(2) + ' Discount : ' + 'ZAR ' + ((Decimal)totalOnceoffAmount).setScale(2);   
            }
        } 
        
        specialNotes = '' + description + ' . A monthly fee of ZAR ' + ((Decimal)monthlyAmount).setScale(2) + ' is payable for dual sim card connectivity which is fitted into your card machines.';
        inputMap.put('amount', String.Valueof(totalAmount));
        inputMap.put('description', 'Adumo Device Outright Purchase');
        inputMap.put('specialNotes','');
        inputMap.put('messageBody', 'Welcome to Sureswipe, an Adumo company, you are almost ready to accept payments on your brand-new card machine! Next steps ,please settle your payment, upload your documents on our client portal. The link will be shared via email.');
        return inputMap;
    }
}