/*
Date created: 31/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-233
*/
@isTest(SeeAllData=false)
public class TransactionListControllerTest 
{
    private static Account testAccount;

    static void setup()
    {
        testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];
        TestDataFactory.createTransactions(testAccount.Id, 3);
    }

    @isTest
    static void retrieval()
    {
        setup();

        Test.startTest();

        List<Transaction__c> results = TransactionListController.getAccountTransactions(testAccount.Id);

        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertEquals(3, results.size());
    }
}