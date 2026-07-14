/*
Date created: 13/09/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1019
*/
@isTest(SeeAllData = false)
public class StockViewControllerTest 
{
    private static Account testAccount;

    private static void setup()
    {
        List<Account> allAccounts = TestDataFactory.createTestAccounts(2, 0, 'GAU');
        testAccount = allAccounts[0];
        Account controlAccount = allAccounts[1];
        Product2 testProduct = TestDataFactory.createTestOnceOffProduct();
        TestDataFactory.createStock(2, testAccount.Id, testProduct.Id);
        TestDataFactory.createStock(5, controlAccount.Id, testProduct.Id);
    }

    @isTest
    static void retrieve()
    {
        setup();

        Test.startTest();

        List<Stock__c> results = StockViewController.getAccountStock(testAccount.Id);

        Test.stopTest();

        System.assertEquals(2, results.size(), 'Too many Stock records');
    }
}