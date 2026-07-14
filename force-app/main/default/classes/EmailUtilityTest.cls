@isTest
public class EmailUtilityTest {
    @testSetup
    static void createTestData(){
        //Lead
        Lead aLead = new Lead();
        aLead.FirstName = 'Test Lead';
        aLead.LastName = 'Created On ' + String.valueOf(DateTime.now());
        aLead.Company = 'Test Company';
        aLead.Email = 'kumar@adumo.com';
        Insert aLead;
        
        // Lead Conversion
        Database.LeadConvert lc = new database.LeadConvert();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];        
        lc.setLeadId(aLead.Id);
        lc.setConvertedStatus(convertStatus.MasterLabel);        
        Database.LeadConvertResult lcr = Database.convertLead(lc);        
        system.debug(lcr.getAccountId());
        system.debug(lcr.getContactId());
        
        // Deal
        Deal__c aDeal = new Deal__c();
        aDeal.Name = 'Test Deal Created On ' + String.valueOf(DateTime.now());
        aDeal.RecordTypeId = Schema.SObjectType.Deal__c.getRecordTypeInfosByDeveloperName().get('Digital_Sales').getRecordTypeId();
        aDeal.Channel__c = 'Digital';
        aDeal.Lead__c = aLead.Id;
        Insert aDeal;       
    }
    @isTest static void testMethod1(){
        
        System.assertEquals(1, [SELECT count(Id) FROM Lead].size(),'Expected test to find a single Lead');
        System.assertEquals(1, [SELECT count(Id) FROM Deal__c].size(),'Expected test to find a single Deal');
        
        List<Deal__c> aDeal = [SELECT Id, Lead__r.Id FROM Deal__c];
        
        List<EmailUtility.requestParam> inputs = new List<EmailUtility.requestParam>();
        EmailUtility.requestParam input = new EmailUtility.requestParam();
        input.recordId = aDeal[0].Id;
        input.templateDeveloperName = 'Payment_Link';
        inputs.add(input);
        
        Test.startTest();
        EmailUtility.SendEmailAndLogActivity(inputs);
        System.assertEquals(limits.getEmailInvocations(), 1);
        Test.stopTest();
        
        
    }
}