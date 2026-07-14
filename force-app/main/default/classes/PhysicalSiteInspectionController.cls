/**
* Author    :   Connor Huglin	
* Date      :   07 July 2021
* Desc      :   generate physical site inspection to PDF
**/
public class PhysicalSiteInspectionController {
    public Deal__c deal {get; set;}
    public String dealId {get; set;}
    public String companyTradingName {get; set;}
    public String ssEmployeeName {get; set;}
    public String undersignerName {get; set;}
    public String undersignerEmplNo {get; set;}
    public Date dateSiteVisited {get; set;}
    public String siteAddress {get; set;}
    public String tradingNameConfirmation {get; set;}
    
    // wrapper for flow elements
    public class PhysicalSiteInspectionWrapper {
        @InvocableVariable public String dealId;
        @InvocableVariable public String companyTradingName;
        @InvocableVariable public String ssEmployeeName;
        @InvocableVariable public String undersignerName;
        @InvocableVariable public String undersignerEmplNo;
        @InvocableVariable public Date dateSiteVisited;
        @InvocableVariable public String siteAddress;
        @InvocableVariable public String tradingNameConfirmation;
    }
    
    public PhysicalSiteInspectionController(){
        system.debug('Id: ' +  ApexPages.currentPage().getParameters().get('id'));
        deal = [SELECT Id, PhysicalSiteInspectionJSON__c FROM Deal__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        
        String JSONString = ApexPages.currentPage().getParameters().get('JSONString');// this is passedas encoded as saving and querying above does not work
        String decodedJSON = EncodingUtil.urlDecode(JSONString, 'UTF-8');
        system.debug('Decoded:'  + decodedJSON);
        
        if(!String.isBlank(decodedJSON)){
            PhysicalSiteInspectionWrapper inspectionData = (PhysicalSiteInspectionWrapper)JSON.deserialize(decodedJSON, PhysicalSiteInspectionWrapper.class);
            dealId = inspectionData.dealId;
 			companyTradingName = inspectionData.companyTradingName;
    		ssEmployeeName = inspectionData.ssEmployeeName;
			undersignerName = inspectionData.undersignerName;
    		undersignerEmplNo = inspectionData.undersignerEmplNo;
    		dateSiteVisited = inspectionData.dateSiteVisited;
			siteAddress = inspectionData.siteAddress;
    		tradingNameConfirmation = inspectionData.tradingNameConfirmation;
        }
    }
    
    @InvocableMethod(label='Generate Physical Site Inspection PDF')
    public static List<Id> saveJSONData(List<PhysicalSiteInspectionWrapper> inputDataLs) {
        system.debug('inputDataLs: ' + inputDataLs);

        List<Id> contentDocumentIds = new List<Id>();
        Set<Id> dealIds = new Set<Id>();
        
        for(PhysicalSiteInspectionWrapper eachInput : inputDataLs) {
            dealIds.add(eachInput.dealId);
        }
        
        Map<Id, Deal__c> dealsMap = new Map<Id, Deal__c>([SELECT Id, PhysicalSiteInspectionJSON__c FROM Deal__c WHERE Id in :dealIds]);
        
        List<Deal__c> dealsToUpdate = new List<Deal__c>();
        for(PhysicalSiteInspectionWrapper eachInput : inputDataLs) {
            Deal__c thisDeal = dealsMap.get(eachInput.dealId);
            thisDeal.PhysicalSiteInspectionJSON__c = JSON.serialize(eachInput);
            dealsToUpdate.add(thisDeal);
        }
        
        update dealsToUpdate;
        
        //Generate PDF and attach to deal with tag
        for(PhysicalSiteInspectionWrapper eachInput : inputDataLs) {
            contentDocumentIds.add(generateAndSavePDF(eachInput.dealId, EncodingUtil.urlEncode(JSON.serialize(eachInput),'UTF-8')));
        }
        
        system.debug('contentDocumentIds: ' + contentDocumentIds);
        return contentDocumentIds;
    }
    
    public String getSFUsername(){
        User currUser = [SELECT Id, Name FROM User WHERE Id =: userinfo.getuserId()];
        return currUser.Name;
    }
    
    public static Id generateAndSavePDF(Id dealId, string URLEncodedJSONString){
        PageReference siteInspectionPDF = new PageReference('/apex/PhysicalSiteInspectionPDF?id=' + dealId + '&JSONString=' + URLEncodedJSONString);
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Site Verification';
        cv.PathOnClient = 'SiteVerification.pdf';
        cv.DocumentType_fileupload__c = 'Site Verification';
        
        if(Test.isRunningTest()) {
            cv.VersionData = Blob.valueOf('Test Content');
        } else {
            cv.VersionData = siteInspectionPDF.getContentAsPDF();
        }
        
        cv.Origin = 'C';
        Insert cv;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = dealId;
        cDe.ShareType = 'I';
        insert cDe;
        return conDoc;
    }
}