@isTest
public class LCC_DocumentRequirementController_Test {
    @isTest
    static void testDocumentController() {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, null);
        List<AccountContactRelation> relations = [Select Id, Roles From AccountContactRelation];
        for(AccountContactRelation eachRole : relations){
            eachRole.Roles = 'Director';
        }
        update relations;
        List<Deal__c> testDeals = TestDataFactory.createDeals(1);
        List<Opportunity> testOpps = TestDataFactory.createOpportunities(testAccounts);
        TestDataFactory.createContentDocument(testDeals[0].Id, 'Proof of banking in entity name');
        TestDataFactory.createContentDocument(testDeals[0].Id, 'ITC Motivation Bank Statements');
        TestDataFactory.createContentDocument(testDeals[0].Id, null);
        testDeals = [Select Id, Account__c from Deal__c];
        List<Contact> testContacts = [Select Id From Contact];
        TestDataFactory.createContentDocument(testContacts[0].Id, 'Proof of Address');
        testDeals[0].Account__c = testAccounts[0].Id;
        testDeals[0].Opportunity__c = testOpps[0].Id;
        update testDeals;

        Test.startTest();
        LCC_DocumentRequirementController.getDocuments(testDeals[0].Id, null, 'FICA', 'Sole Proprietor', new List<String>{'Draft Contract'});
        LCC_DocumentRequirementController.getDocuments(testOpps[0].Id, null, 'FICA', 'Sole Proprietor', new List<String>{'Draft Contract'});
        LCC_DocumentRequirementController.submitToContractsTeam(testDeals[0].Id, 'Deal__c');
        LCC_DocumentRequirementController.deleteDocument([Select Id From ContentDocument Limit 1].Id);
        Test.stopTest();
    }
}