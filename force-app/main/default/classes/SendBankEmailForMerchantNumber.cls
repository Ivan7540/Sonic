/**
* Author    :   Swapnil Walse
* Date      :   13 April 2021
* Desc      :   Send documents to Nedbank or merchant bank for getting merchant ids
*               custom method as we need to attach documents from SF
*               
**/
public class SendBankEmailForMerchantNumber {
    public static final String messageSubject = 'RPA Merchant Onboarding - {0}';
    public static final String emailAddress = 'ISOmerchants@nedbank.co.za'; //if sandbox, then its replaced with user's email address
    
    public class requestInput{
        @InvocableVariable
        public String dealId;
        @InvocableVariable
        public List<Id> contentDocumentIds;
        @InvocableVariable
        public String concatenatedContentDocumentIds;
        @InvocableVariable
        public String emailBody;
		@InvocableVariable
        public String recordId;
		@InvocableVariable
        public String oppEmailBody;
    }
    
    @InvocableMethod
    public static List<Boolean> sendEmailToBank(List<requestInput> inputs){
        
        List<Boolean> returnMessage = new List<Boolean>();
        Set<Id> dealIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        system.debug('inputs ==  '+inputs);
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        
        for(requestInput eachInput : inputs){
            if(eachInput.dealId != null && eachInput.dealId != '' && eachInput.dealId != ' ') {
                dealIds.add(Id.valueOf(eachInput.dealId));
            }
            
            if(eachInput.recordId != null && eachInput.recordId != '' && eachInput.recordId != ' ') {
                opportunityIds.add(Id.valueOf(eachInput.recordId));
            }
            
            if(!String.isEmpty(eachInput.concatenatedContentDocumentIds)){
                List<String> ids = eachInput.concatenatedContentDocumentIds.split(',');
                if(eachInput.contentDocumentIds == null){
                    eachInput.contentDocumentIds = new List<Id>();
                }
                eachInput.contentDocumentIds.addAll(ids);
            }
            contentDocumentIds.addAll(eachInput.contentDocumentIds);
        }
        system.debug('contentDocumentIds == ' + contentDocumentIds);
        
        Map<Id, Deal__c> dealsMap = new Map<Id, Deal__c>();
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>();
        
        if(dealIds.size() > 0){
			dealsMap = new Map<Id, Deal__c>([
                Select Id,
                Account__r.Name,
                Account__r.TradingName__c,
                Opportunity__c
                From Deal__c where Id in :dealIds
            ]);
        }
        
        if(opportunityIds.size() > 0){
            opportunitiesMap = new Map<Id, Opportunity>([
                Select Id,
                Account.Name,
                Account.TradingName__c
                From Opportunity where Id in :opportunityIds
            ]);
        }

        system.debug('opportunitiesMap ===: ' + opportunitiesMap);
        Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>([
            Select Id,
            Title,
            LatestPublishedVersionId,
            LatestPublishedVersion.DocumentType_fileupload__c
            From ContentDocument
            Where Id in :contentDocumentIds
        ]);
        //update file names as needed by RPA
        updateFileNames(contentDocMap);
        
        for(requestInput eachInput : inputs){
            Messaging.SingleEmailMessage bankEmail = new Messaging.SingleEmailMessage();
            
            if(dealsMap.size() > 0){
                Deal__c thisDeal = dealsMap.get(eachInput.dealId);
                system.debug('thisDeal == ' + thisDeal);
                
                if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox)// if sandbox, send to user instead of bank
                    bankEmail.setToAddresses(new String[]{UserInfo.getUserEmail()});
                else bankEmail.setToAddresses(new String[]{emailAddress});            
                bankEmail.setCcAddresses(new String[]{UserInfo.getUserEmail()});
                bankEmail.setSubject(String.format(messageSubject, new List<String>{thisDeal.Account__r.TradingName__c}));
                bankEmail.setPlainTextBody(eachInput.emailBody);
                system.debug('bankEmail == ' + bankEmail);
                
                List<Id> versionIds = new List<Id>();
                for(Id eachId : eachInput.contentDocumentIds){
                    system.debug('contentDocMap.get(eachId) == '+contentDocMap.get(eachId));
                    versionIds.add(contentDocMap.get(eachId).LatestPublishedVersionId);
                }
                
                bankEmail.setEntityAttachments(versionIds);
                if(!String.isBlank(thisDeal.Opportunity__c)){
                    bankEmail.setWhatId(thisDeal.Opportunity__c);
                }else{
                    bankEmail.setWhatId(thisDeal.Id);
                } 
            } else {
                Opportunity thisOpportunity = opportunitiesMap.get(eachInput.recordId);
                system.debug('thisOpp == ' + thisOpportunity);
                
                if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox)// if sandbox, send to user instead of bank
                    bankEmail.setToAddresses(new String[]{UserInfo.getUserEmail()});
                else bankEmail.setToAddresses(new String[]{emailAddress});            
                bankEmail.setCcAddresses(new String[]{UserInfo.getUserEmail()});
                bankEmail.setSubject(String.format(messageSubject, new List<String>{thisOpportunity.Account.TradingName__c}));
                bankEmail.setPlainTextBody(eachInput.oppEmailBody);
                system.debug('bankEmail == ' + bankEmail);
                
                List<Id> versionIds = new List<Id>();
                for(Id eachId : eachInput.contentDocumentIds){
                    system.debug('contentDocMap.get(eachId) == '+contentDocMap.get(eachId));
                    versionIds.add(contentDocMap.get(eachId).LatestPublishedVersionId);
                }
                
                bankEmail.setEntityAttachments(versionIds);
                /*if(!String.isBlank(thisDeal.Opportunity__c)){
                    bankEmail.setWhatId(thisDeal.Opportunity__c);
                }else{
                    bankEmail.setWhatId(thisDeal.Id);
                }*/
                
                bankEmail.setWhatId(thisOpportunity.Id);
            }

            
            bankEmail.setSaveAsActivity(true);
            emailsList.add(bankEmail);
        }
        
        List<Messaging.sendEmailResult> results = Messaging.sendEmail(emailsList);
        for(Messaging.sendEmailResult eachResult : results){
            returnMessage.add(eachResult.isSuccess());
        }
        return returnMessage;
    }
    public static Map<String, String> getSubstituteName(){
        Map<String, String> substituteNameMap = new Map<String, String>();
        substituteNameMap.put('ID-GreenBarCode', 'ID-GreenBarCode');
        substituteNameMap.put('ID-Smartcard', 'ID-Smartcard');
        substituteNameMap.put('Certificate of Incorporation(CM1)', 'Company-Reg');
        substituteNameMap.put('Resolution to identify who may act on behalf of the entity', 'Resolution');
        substituteNameMap.put('Beneficial Owner Form', 'RBBO');
        substituteNameMap.put('Liquor License', 'Liquor-Licence');
        substituteNameMap.put('Proof of banking in entity name', 'Proof-of-Bank-Account');
        substituteNameMap.put('Proof of Business Address', 'POA');
        return substituteNameMap;
    }
    public static void updateFileNames(Map<Id,ContentDocument> contentDocsMap){
        List<ContentDocument> docsToUpdate = new List<contentDocument>();
        Map<String, String> substituteNameMap = getSubstituteName();
        for(Id docId : contentDocsMap.keySet()){
            ContentDocument thisDoc = contentDocsMap.get(docId);
            if(substituteNameMap.containsKey(thisDoc.LatestPublishedVersion.DocumentType_fileupload__c)){
                thisDoc.Title = substituteNameMap.get(thisDoc.LatestPublishedVersion.DocumentType_fileupload__c);
                docsToUpdate.add(thisDoc);
            }
        }
        update docsToUpdate;
    }
}