/**
* Author	:	Swapnil Walse
* Date		:	19 April 2021
* Desc		:	Test class for Remote Signing Interface
* 			:	SeeAllData set to true to be able to see templates
* 			:	 
* 				
**/
@IsTest(SeeAllData = true)
public class HelloSignInterface_Test {
    @IsTest
    static void testSigningRequest(){
        
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1,1,'');
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        Lead testLead = TestDataFactory.createLead('Other');
        List<Deal__c> testDeals = TestDataFactory.createDeals(1);

        List<HelloSign__HelloSign_Signature_Request__c> sigRecs = new List<HelloSign__HelloSign_Signature_Request__c>();
        HelloSign__HelloSign_Signature_Request__c sigRec = new HelloSign__HelloSign_Signature_Request__c(
            HelloSign__Signature_Request_ID__c = 'dca816957681d7b1740e34aed0200153da735478',
            HelloSign__Document_Name__c = 'Test Title',
            HelloSign__Message2__c = 'Test Message',
            HelloSign__Total_Signers__c = 1,
            HelloSign__Completed_Signers__c = 0,
            HelloSign__Latest_Action__c = 'Awaiting Signature',
            HelloSign__Active__c = true,
            HelloSign__Related_Object_Id__c = testOpties[0].Id,
            HelloSign__Opportunity__c = testOpties[0].Id,
            HelloSign__Account__c = testAccounts[0].Id
        );
        sigRecs.add(sigRec);
        sigRec = new HelloSign__HelloSign_Signature_Request__c(
            HelloSign__Signature_Request_ID__c = 'dca817957681d7b1740e34aed0200153da735478',
            HelloSign__Document_Name__c = 'Test Title',
            HelloSign__Message2__c = 'Test Message',
            HelloSign__Total_Signers__c = 1,
            HelloSign__Completed_Signers__c = 0,
            HelloSign__Latest_Action__c = 'Awaiting Signature',
            HelloSign__Active__c = true,
            HelloSign__Related_Object_Id__c = testAccounts[0].Id,
            HelloSign__Account__c = testAccounts[0].Id
        );
        sigRecs.add(sigRec);
        
        sigRec = new HelloSign__HelloSign_Signature_Request__c(
            HelloSign__Signature_Request_ID__c = 'dca818957681d7b1740e34aed0200153da735478',
            HelloSign__Document_Name__c = 'Test Title',
            HelloSign__Message2__c = 'Test Message',
            HelloSign__Total_Signers__c = 1,
            HelloSign__Completed_Signers__c = 0,
            HelloSign__Latest_Action__c = 'Awaiting Signature',
            HelloSign__Active__c = true,
            HelloSign__Related_Object_Id__c = testLead.Id,
            HelloSign__Lead__c = testLead.Id,
            HelloSign__Account__c = testAccounts[0].Id
        );
        sigRecs.add(sigRec);
        
        sigRec = new HelloSign__HelloSign_Signature_Request__c(
            HelloSign__Signature_Request_ID__c = 'dca818987681d7b1740e34aed0200153da735478',
            HelloSign__Document_Name__c = 'Test Title',
            HelloSign__Message2__c = 'Test Message',
            HelloSign__Total_Signers__c = 1,
            HelloSign__Completed_Signers__c = 0,
            HelloSign__Latest_Action__c = 'Awaiting Signature',
            HelloSign__Active__c = true,
            HelloSign__Related_Object_Id__c = testDeals[0].Id,
            Deal__c = testDeals[0].Id
        );
        sigRecs.add(sigRec);
        
        Contact testContact = [Select Id,
                               AccountId 
                               from Contact 
                               where AccountId = :testAccounts[0].Id];
        sigRec = new HelloSign__HelloSign_Signature_Request__c(
            HelloSign__Signature_Request_ID__c = 'dca819957681d7b1740e34aed0200153da735478',
            HelloSign__Document_Name__c = 'Test Title',
            HelloSign__Message2__c = 'Test Message',
            HelloSign__Total_Signers__c = 1,
            HelloSign__Completed_Signers__c = 0,
            HelloSign__Latest_Action__c = 'Awaiting Signature',
            HelloSign__Active__c = true,
            HelloSign__Related_Object_Id__c = testContact.Id,
            HelloSign__Contact__c = testContact.Id,
            HelloSign__Account__c = testContact.AccountId);
        sigRecs.add(sigRec);
        insert sigRecs;
        
        //Create documents for testing
        List<ContentVersion> cvDocs = new List<ContentVersion>();
        cvDocs.add(new ContentVersion(
            Title = 'Document_ToMakeUnique8767888765544',
            PathOnClient = 'Document_ToMakeUnique8767888765544.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        ));
        insert cvDocs;
        List<ContentDocument> documents = [SELECT Id,
                                           Title,
                                           LatestPublishedVersionId 
                                           FROM ContentDocument
                                           Where Title = 'Document_ToMakeUnique8767888765544'];
        system.debug(documents);
        
        Map<string,Map<string,string>> signerNames = new Map<String, Map<String,String>>();
        Map<String, String> signerEmail = new Map<String,String>{'Swapnil Walsea' => 'swapnil.walse@tetrad.co.za'};
        signerNames.put('BAM', signerEmail);
        signerEmail = new Map<String,String>{'Swapnil Walseb' => 'swapnil.walse@tetrad.co.za'};
            signerNames.put('Regional Manager', signerEmail);
        signerEmail = new Map<String,String>{'Swapnil Walsec' => 'swapnil.walse@tetrad.co.za'};
            signerNames.put('Owner1', signerEmail);
        
        HelloSign__Template__c newTemplate = new HelloSign__Template__c(Name='Test Template',
                                                                        HelloSign__Status__c='Active');
        insert newTemplate;
        
        List<HelloSign__SignerRole__c> newRoles = new List<HelloSign__SignerRole__c>();
        HelloSign__SignerRole__c newRole = new HelloSign__SignerRole__c(
            Name = 'signer1',
            HelloSign__RoleType__c = 'Specific Email',
            HelloSign__SignerAction__c = 'signer',
            HelloSign__SignerOrder__c = 0,
            HelloSign__Template__c = newTemplate.Id
        );
        newRoles.add(newRole);
        newRole = new HelloSign__SignerRole__c(
            Name = 'signer2',
            HelloSign__RoleType__c = 'Specific Email',
            HelloSign__SignerAction__c = 'signer',
            HelloSign__SignerOrder__c = 1,
            HelloSign__Template__c = newTemplate.Id
        );
        newRoles.add(newRole);
        newRole = new HelloSign__SignerRole__c(
            Name = 'signer3',
            HelloSign__RoleType__c = 'Specific Email',
            HelloSign__SignerAction__c = 'signer',
            HelloSign__SignerOrder__c = 2,
            HelloSign__Template__c = newTemplate.Id
        );
        newRoles.add(newRole);
        insert newRoles;
        Test.startTest();
        
        HelloSignInterface.sendSigningRequest(testOpties[0].Id, 
                                              'Test Title',
                                              'Test Subject',
                                              'Test Message',
                                              new List<Id>{documents[0].Id},
                                              new List<HelloSignSignerName>{
                                                  new HelloSignSignerName('signer1', 'Swapnil Walse','swapnil.walse@tetrad.co.za'),
                                                  new HelloSignSignerName('signer2', 'Swapnil Walseb','swapnil.walse@tetrad.co.za')
                                              },
                                              new List<String>{'swapnil.walse@tetrad.co.za'},
                                              true,
                                              true);
        //Test sending with template
        List<HelloSignRequestParams> params = new List<HelloSignRequestParams>();
        HelloSignRequestParams param = new HelloSignRequestParams();
        param.ccEmail = new List<String>{'swapnil.walse@tetrad.co.za'};
            param.isTestMode = true;
        param.originObjectId = testOpties[0].Id;
        param.sendImmediately = true;
        param.sfdcTemplateId = newTemplate.Id;
        param.signerNames = new List<HelloSignSignerName>();
        
        param.signerNames.add(new HelloSignSignerName('signer1', 'Swapnil Walsea', 'swapnil.walse@tetrad.co.za'));
        param.signerNames.add(new HelloSignSignerName('signer2', 'Swapnil Walseb', 'swapnil.walse@tetrad.co.za'));
        param.signerNames.add(new HelloSignSignerName('signer3', 'Swapnil Walsec', 'swapnil.walse@tetrad.co.za'));
        
        params.add(param);
        
        SigningRequestWithTemplateInvocable.sendSigningRequestWithTemplate(params);
        
        HelloSignSignerName testName = new HelloSignSignerName();
        
        //Test GetRecentSigningRequest
        HelloSignRecentSigningRequest.getRecentSigningRequestInvocable(new List<Id>{sigRecs[0].Id});  
        HelloSignRecentSigningRequest.getRecentSigningRequestInvocable(new List<Id>{testAccounts[0].Id}); 
        HelloSignRecentSigningRequest.getRecentSigningRequestInvocable(new List<Id>{testOpties[0].Id});
        HelloSignRecentSigningRequest.getRecentSigningRequestInvocable(new List<Id>{testLead.Id});
        HelloSignInterface.convertUnixDateTime(1618844765);
        Test.stopTest();
    }
}