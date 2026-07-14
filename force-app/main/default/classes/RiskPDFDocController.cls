/**
* Author    :   Swapnil Walse
* Date      :   11 May 2021
* Desc      :   controller for generating risk report pdf
*               
**/
public class RiskPDFDocController {
    public class RiskReportData{
        @InvocableVariable public String dealId;
        @InvocableVariable public Boolean areaStigma;
        @InvocableVariable public String explainAreaStigma;
        @InvocableVariable public Boolean premisesFunctional;
        @InvocableVariable public String explainPremisesFunctional;
        @InvocableVariable public Boolean stockHeldElsewhere;
        @InvocableVariable public Boolean didStockInspection;
        @InvocableVariable public Boolean ownerSpeaksEnglish;
        @InvocableVariable public Boolean wasTranslatorPresent;
        @InvocableVariable public String translatorContactNo;
        @InvocableVariable public Boolean merchantSellHighValueItems;
        @InvocableVariable public String explainHighValueItems;
        @InvocableVariable public Boolean fakeIllegalItems;
        @InvocableVariable public String explainFakeIllegalItems;
        @InvocableVariable public Boolean acceptMOTO;
        @InvocableVariable public String explainMOTO;
        @InvocableVariable public Boolean merchantOverEager;
        @InvocableVariable public String explainMerchantOverEager;
        @InvocableVariable public Boolean googleSearch;
        @InvocableVariable public String explainGoogleSearch;
        @InvocableVariable public Boolean BAMConfirmation;
    }
    
    public final Deal__c deal{get;set;}
    
    public String dealId{get;set;}
    public Boolean areaStigma{get;set;}
    public String explainAreaStigma{get;set;}
    public Boolean premisesFunctional{get;set;}
    public String explainPremisesFunctional{get;set;}
    public Boolean stockHeldElsewhere{get;set;}
    public Boolean didStockInspection{get;set;}
    public Boolean ownerSpeaksEnglish{get;set;}
    public Boolean wasTranslatorPresent{get;set;}
    public String translatorContactNo{get;set;}
    public Boolean merchantSellHighValueItems{get;set;}
    public String explainHighValueItems{get;set;}
    public Boolean fakeIllegalItems{get;set;}
    public String explainFakeIllegalItems{get;set;}
    public Boolean acceptMOTO{get;set;}
    public String explainMOTO{get;set;}
    public Boolean merchantOverEager{get;set;}
    public String explainMerchantOverEager{get;set;}
    public Boolean googleSearch{get;set;}
    public String explainGoogleSearch{get;set;}
    public Boolean BAMConfirmation{get;set;}
    
    
    public RiskPDFDocController(){
        this.deal = [Select Id,
                     Account__c,
                     Account__r.Name,
                     Owner.Name,
                     RiskReportJSON__c
                     From Deal__c
                     where Id = : ApexPages.currentPage().getParameters().get('id')];
        String JSONString = ApexPages.currentPage().getParameters().get('JSONString');// this is passedas encoded as saving and querying above does not work
        String decodedJSON = EncodingUtil.urlDecode(JSONString, 'UTF-8');
        system.debug('Decoded:'  + decodedJSON);
        if(!String.isBlank(decodedJSON)){
            RiskReportData riskData = (RiskReportData)JSON.deserialize(decodedJSON, RiskReportData.class);
            this.dealId = riskData.dealId;
            this.areaStigma = riskData.areaStigma;
            this.explainAreaStigma = riskData.explainAreaStigma;
            this.premisesFunctional = riskData.premisesFunctional;
            this.explainPremisesFunctional = riskData.explainPremisesFunctional;
            this.stockHeldElsewhere = riskData.stockHeldElsewhere;
            this.didStockInspection = riskData.didStockInspection;
            this.ownerSpeaksEnglish = riskData.ownerSpeaksEnglish;
            this.wasTranslatorPresent = riskData.wasTranslatorPresent;
            this.translatorContactNo = riskData.translatorContactNo;
            this.merchantSellHighValueItems = riskData.merchantSellHighValueItems;
            this.explainHighValueItems = riskData.explainHighValueItems;
            this.fakeIllegalItems = riskData.fakeIllegalItems;
            this.explainFakeIllegalItems = riskData.explainFakeIllegalItems;
            this.acceptMOTO = riskData.acceptMOTO;
            this.explainMOTO = riskData.explainMOTO;
            this.merchantOverEager = riskData.merchantOverEager;
            this.explainMerchantOverEager = riskData.explainMerchantOverEager;
            this.googleSearch = riskData.googleSearch;
            this.explainGoogleSearch = riskData.explainGoogleSearch;
            system.debug('GS:' + this.explainGoogleSearch);
            this.BAMConfirmation = riskData.BAMConfirmation;
        }
    }
    
    @InvocableMethod
    public Static List<Id> saveRiskJSON(List<RiskReportData> inputs){
        List<Id> contentDocumentIds = new List<Id>();
        Set<Id> dealIds = new Set<Id>();
        for(RiskReportData eachInput : inputs){
            dealIds.add(eachInput.dealId);
        }
        Map<Id, Deal__c> dealsMap = new Map<Id, Deal__c>([Select Id,
                                                          Account__c,
                                                          Account__r.Name,
                                                          Owner.Name,
                                                          RiskReportJSON__c
                                                          From Deal__c
                                                          where Id in :dealIds]);
        
        List<Deal__c> dealsToUpdate = new List<Deal__c>();
        
        for(RiskReportData eachInput : inputs){
            Deal__c thisDeal = dealsMap.get(eachInput.dealId);
            thisDeal.RiskReportJSON__c = JSON.serialize(eachInput);
            dealsToUpdate.add(thisDeal);
        }
        update dealsToUpdate;
        
        //Generate PDF and attach to deal with tag
        for(RiskReportData eachInput : inputs){
            contentDocumentIds.add(generateAndSavePDF(eachInput.dealId, EncodingUtil.urlEncode(JSON.serialize(eachInput),'UTF-8')));
        }
        return contentDocumentIds;
    }

    public static Id generateAndSavePDF(Id dealId, string URLEncodedJSONString){
        PageReference riskPDF = new PageReference('/apex/RiskPDFDoc?id=' + dealId + '&JSONString=' + URLEncodedJSONString);
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Risk Report';
        cv.PathOnClient = 'RiskReport.pdf';
        cv.DocumentType_fileupload__c = 'Risk Report';
        if(Test.isRunningTest()){
            cv.VersionData = Blob.valueOf('Test Content');
        }else{
            cv.VersionData = riskPDF.getContentAsPDF();
        }
        
        cv.Origin = 'C';
        Insert cv;
        Id conDoc = [SELECT
                     ContentDocumentId
                     FROM ContentVersion 
                     WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = dealId;
        cDe.ShareType = 'I';
        insert cDe;
        return conDoc;
    }
}