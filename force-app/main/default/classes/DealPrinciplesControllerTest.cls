@IsTest
private class DealPrinciplesControllerTest
{
    @IsTest
    static void testMethods(){
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1,1,'');
        List<Deal__c> testDeals = TestDataFactory.createDeals(1);
        testDeals[0].Account__c = testAccounts[0].Id;
        update testDeals;
        List<Contact> testContacts = [Select Id, FirstName, LastName, Phone From Contact];
        List<String> deletedIds = new List<String>();
        Test.startTest();
        List<DealPrinciplesController.DealPrinciple> dealPrinciples = DealPrinciplesController.getAccountContacts(testDeals[0].Id);
        DealPrinciplesController.saveContacts(JSON.serialize(dealPrinciples), testDeals[0].Id, JSON.serialize(deletedIds));
        Test.stopTest();
    }
}