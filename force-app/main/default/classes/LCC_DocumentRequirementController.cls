/**
* Author	:	Swapnil Walse
* Date		:	07 May 2021
* Desc		:	controller for document requirement component
* 			:	shows both contact and deal required documents.
* 			:	
*               
* 				
**/
global class LCC_DocumentRequirementController 
{
    private static Set<String> BO_RELATED = new Set<String>{'Associated parties/Source of Funds', 'Beneficial Owner Calculator', 'Ownership and Control structure (OC)'};
    
    @AuraEnabled
    public static documentRequirement getDocuments(Id recordId, String sObjectName, String requirementType, String businessType, List<String> hideDocuments)
    {
        Id accountId;
        Boolean hasBOForm = false; // added by Connor: 2021-10-05 for ps-854

        if(String.isBlank(sObjectName))
        {
            sObjectName = String.valueOf(recordId.getSObjectType());
        }

        documentRequirement requirement = new documentRequirement();
        requirement.isRequirementsComplete = true; //set it to true first, if any required document is missing then it is set to false
        requirement.documents = new List<DocumentRecord>();
        requirement.otherDocuments = new List<FileExplorerFile__c>();
        List<FileExplorerFile__c> taggedDocuments = new List<FileExplorerFile__c>();
        List<FileExplorerFile__c> otherDocuments = new list<FileExplorerFile__c>();        
                
        if(sObjectName == 'Account')
        {
            Account acc = getAccountById(recordId);
            businessType = acc.BusinessType__c;
            requirementType = 'FICA';
            accountId = acc.Id;
        }
        else if(sObjectName == 'Deal__c')
        {
            Deal__c deal = getDealById(recordId);
            if(deal.Account__r.BusinessType__c != null)
            {
                businessType = deal.Account__r.BusinessType__c;
            } 
            requirementType = 'FICA';
            accountId = deal.Account__c;
        }
        else if(sObjectName == 'Opportunity')
        {
            Opportunity opp = getOpportunityById(recordId);

            if(opp.Account.BusinessType__c != null) 
            {
                businessType = opp.Account.BusinessType__c;
            }
            
            if(!opp.Deals__r.isEmpty())
            {
                recordId = opp.Deals__r[0].Id;
            }

            requirementType = 'FICA';
            accountId = opp.AccountId;
        }
        else if(sObjectName == 'Contact')
        {
            requirementType = 'KYC';
        }
        
        List<FileExplorerFile__c> files = getRelatedFiles(new Set<Id>{recordId}, hideDocuments);
        
        for(FileExplorerFile__c eachFile : files)
        {
            if(String.isBlank(eachFile.Tags__c))
            {
                otherDocuments.add(eachFile);                
            }
            else 
            {
                taggedDocuments.add(eachFile);
                if(eachFile.Tags__c.contains('Combined FICA Documents'))
                {
                    requirement.combinedFile = eachFile;
                }
                
                // if BO form is attached, we do not require some forms
                if(eachFile.Tags__c.contains('Beneficial Owner Form'))
                {
                    hasBOForm = true;
                }
            }
        }
                
        List<DocumentRequirement__mdt> FICArequirementsList = getRequirements(businessType, 'FICA');

        for(DocumentRequirement__mdt eachReq : FICArequirementsList)
        {            
            documentRecord thisRec = new documentRecord();
            thisRec.attachedDocuments = new List<FileExplorerFile__c>();
            
            thisRec.documentDescription = eachReq.DocumentName__c;
            
            thisRec.documentType = new List<String>();
            thisRec.isRequired = eachReq.Required__c;
            thisRec.documentType.add(eachReq.DocumentType1__c); //this is required field so no need to check blank
            thisRec.isComplete = false;
            
            if(!String.isBlank(eachReq.DocumentType2__c))
            {
                thisRec.documentType.add(eachReq.DocumentType2__c);
            }
            if(!String.isBlank(eachReq.DocumentType3__c))
            {
                thisRec.documentType.add(eachReq.DocumentType3__c);
            }
            if(!String.isBlank(eachReq.DocumentType4__c))
            {
                thisRec.documentType.add(eachReq.DocumentType4__c);
            } 
            if(!String.isBlank(eachReq.DocumentType5__c))
            {
                thisRec.documentType.add(eachReq.DocumentType5__c);
            }
            
            requirement.businessType = businessType;
            
            for(String documentType : thisRec.documentType)
            {
                for (Integer i = (taggedDocuments.size() - 1); i >= 0; i--)
                {
                    if((!taggedDocuments.isEmpty()))
                    {
                        if(taggedDocuments.get(i).Tags__c.contains(documentType))
                        {
                            thisRec.attachedDocuments.add(taggedDocuments.remove(i));
                            thisRec.isComplete = true;
                        }
                    }
                }
            }
            
            if((!thisRec.isComplete) && eachReq.Required__c)
            {
                requirement.isRequirementsComplete = false;
            }
            
            // if BO Form is attached, we do not require forms for Associated parties/Source of Funds; Beneficial Owner Calculator; Ownership and Control structure (OC)
            if(hasBOForm)
            {
                if(!BO_RELATED.contains(eachReq.DocumentType1__c))
                {
                    requirement.documents.add(thisRec);
                }
            } 
            else 
            {
                requirement.documents.add(thisRec);
            }
        }

        requirement.otherDocuments = new List<FileExplorerFile__c>();
        requirement.otherDocuments.addAll(taggedDocuments);
        requirement.otherDocuments.addAll(otherDocuments);
        
        //Get Contact
        requirement.contactDetails = new List<contactDetails>();
        List<AccountContactRelation> relations = getRelationsForAccount(accountId);
        Set<Id> contactIds = new Set<Id>();
        
        for(AccountContactRelation eachRelation : relations)
        {
            contactIds.add(eachRelation.ContactId);
        }
        
        List<FileExplorerFile__c> contactFiles = getRelatedFiles(contactIds, new List<String>{null});
        
        Map<Id, List<FileExplorerFile__c>> contactFilesMap = new Map<Id, List<FileExplorerFile__c>>();
        for(FileExplorerFile__c eachFile : contactFiles)
        {
            if(contactFilesMap.containsKey(eachFile.LinkedEntityId__c))
            {
                contactFilesMap.get(eachFile.LinkedEntityId__c).add(eachFile);
            }
            else 
            {
                contactFilesMap.put(eachFile.LinkedEntityId__c, new List<FileExplorerFile__c>{eachFile});
            }
        }
        
        List<DocumentRequirement__mdt> KYCrequirementsList = getRequirements(businessType, 'KYC');
        List<documentRecord> contactDocs = new List<documentRecord>();
        
        for(DocumentRequirement__mdt eachReq : KYCrequirementsList)
        {
            documentRecord thisRec = new documentRecord();
            thisRec.attachedDocuments = new List<FileExplorerFile__c>();            
            thisRec.documentDescription = eachReq.DocumentName__c;            
            thisRec.documentType = new List<String>();
            thisRec.isRequired = eachReq.Required__c;
            thisRec.documentType.add(eachReq.DocumentType1__c); //this is required field so no need to check blank
            thisRec.isComplete = false;
            
            if(!String.isBlank(eachReq.DocumentType2__c))
            {
                thisRec.documentType.add(eachReq.DocumentType2__c);
            }

            if(!String.isBlank(eachReq.DocumentType3__c))
            {
                thisRec.documentType.add(eachReq.DocumentType3__c);
            }

            if(!String.isBlank(eachReq.DocumentType4__c))
            {
                thisRec.documentType.add(eachReq.DocumentType4__c);
            } 

            if(!String.isBlank(eachReq.DocumentType5__c))
            {
                thisRec.documentType.add(eachReq.DocumentType5__c);
            }

            contactDocs.add(thisRec);
        }
        
        for(AccountContactRelation eachRelation : relations)
        {
            contactDetails thisContactDetail = new contactDetails();
            thisContactDetail.contactId = eachRelation.ContactId;
            thisContactDetail.contactName = eachRelation.Contact.Name;
            thisContactDetail.contactPhone = eachRelation.Contact.MobilePhone;
            thisContactDetail.contactRole = eachRelation.Roles;
            thisContactDetail.contactEmail = eachRelation.Contact.Email;
            thisContactDetail.documents = (List<documentRecord>)JSON.deserialize(JSON.serialize(contactDocs), List<documentRecord>.class);
            List<FileExplorerFile__c> contactTaggedDocuments = contactFilesMap.containsKey(eachRelation.ContactId)? contactFilesMap.get(eachRelation.ContactId): new List<FileExplorerFile__c>();
            
            for(documentRecord eachDoc : thisContactDetail.documents)
            {
                for(String documentType : eachDoc.documentType)
                {
                    for (Integer i = (contactTaggedDocuments.size() - 1); i >= 0; i--)
                    {
                        if((!contactTaggedDocuments.isEmpty()) && contactTaggedDocuments.get(i).Tags__c.contains(documentType))
                        {
                            eachDoc.attachedDocuments.add(contactTaggedDocuments.remove(i));
                            eachDoc.isComplete = true;
                        }
                    }
                }

                if((!eachDoc.isComplete) && eachDoc.isRequired)
                {
                    requirement.isRequirementsComplete = false;
                }
            }

            requirement.contactDetails.add(thisContactDetail);
        }    

        return requirement;
    }
    
    @AuraEnabled
    public static String deleteDocument(String documentId)
    {
        ContentDocument docToDelete = new ContentDocument();
        docToDelete.Id = documentId;
        delete docToDelete;
        return 'Success';
    }
    
    @AuraEnabled
    public static string submitToContractsTeam(Id recordId, String sObjectName)
    {
        if(sObjectName == null)
        {
            sObjectName = String.valueOf(recordId.getSObjectType());
        }
        
        if(sObjectName == 'Deal__c')
        {
            Deal__c deal = getDealById(recordId);

            if(!deal.AttachmentAdded__c)
            {
                deal.AttachmentAdded__c = true;
                update deal;
                return 'success';
            }
            else
            {
                throw new AuraHandledException('Deal already submitted');
            }
        }
        else
        {
            throw new AuraHandledException('Cannot submit deal from object: ' + sObjectName);
        }
    }

    public static Deal__c getDealById(Id dealId)
    {
        return 
        [
            SELECT  Id, 
                    Account__c,
                    Account__r.BusinessType__c, 
                    AttachmentAdded__c,
                    Opportunity__c,
                    Status__c,
                    Lead__r.ConvertedContactId
            FROM Deal__c
            WHERE Id = :dealId
            LIMIT 1
        ];
    }

    public static Account getAccountById(Id accId)
    {
        return
        [
            SELECT  Id, 
                    BusinessType__c 
            FROM Account 
            WHERE Id = :accId 
            LIMIT 1
        ];
    }

    private static Opportunity getOpportunityById(Id oppId)
    {
        return
        [
            SELECT  Id,
                    AccountId,
                    Account.BusinessType__c,
                    (
                        SELECT Id FROM Deals__r
                    )
            FROM Opportunity 
            WHERE Id = :oppId
            LIMIT 1
        ];
    }

    private static List<FileExplorerFile__c> getRelatedFiles(Set<Id> linkedEntityIds, List<String> excluded)
    {
        return
        [
            SELECT  Id,
                    LinkedEntityId__c,
                    ContentDocumentId__c,
                    Tags__c
            FROM FileExplorerFile__c
            WHERE LinkedEntityId__c IN :linkedEntityIds
            AND Tags__c NOT IN :excluded
        ];
    }

    private static List<DocumentRequirement__mdt> getRequirements(String businessType, String requirementType)
    {
        return
        [
            SELECT  Id,
                    MasterLabel,
                    BusinessType__c,
                    Disabled__c,
                    DocumentType1__c,
                    DocumentType2__c,
                    DocumentType3__c,
                    DocumentType4__c,
                    DocumentType5__c,
                    Required__c,
                    RequirementType__c,
            		DocumentName__c
            FROM DocumentRequirement__mdt
            WHERE BusinessType__r.MasterLabel = :businessType
            AND RequirementType__c = :requirementType
            AND Disabled__c = false
        ];
    }

    public static List<AccountContactRelation> getRelationsForAccount(Id accId)
    {
        return
        [
            SELECT  Id,
                    AccountId,
                    ContactId,
                    Contact.Name,
                    Contact.MobilePhone,
                    Contact.Email,
                    Roles
            FROM AccountContactRelation
            WHERE AccountId = :accId
            AND Roles INCLUDES ('Director')
        ];
    }
    
    global class documentRequirement
    {
        @AuraEnabled
        public List<FileExplorerFile__c> otherDocuments;
        @AuraEnabled
        public List<documentRecord> documents;
        @AuraEnabled
        public Boolean isRequirementsComplete;
        @AuraEnabled
        public String businessType;
        @AuraEnabled
        public List<contactDetails> contactDetails;
        @AuraEnabled
        public FileExplorerFile__c combinedFile;
    }

    public class  contactDetails
    {
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String contactEmail;
        @AuraEnabled
        public String contactPhone;
        @AuraEnabled
        public String contactRole;
        @AuraEnabled
        public List<documentRecord> documents;
    }
    
    public class documentRecord
    {
        @AuraEnabled
        public List<FileExplorerFile__c> attachedDocuments;
        @AuraEnabled
        public String documentDescription;
        @AuraEnabled
        public String documentTag;
        @AuraEnabled
        public List<String> documentType;
        @AuraEnabled
        public Boolean isRequired;
        @AuraEnabled
        public Boolean isComplete;
    }
}