/*
Date created: 08/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-214
*/
@isTest(SeeAllData=false)
public class BillingListControllerTest 
{
    private static Account testAccount;
    private static Contract testSubContract;
    private static Contract testRateContract;

    private static void setup()
    {
        Product2 testSubProduct = TestDataFactory.createTestSubscriptionProduct();
        Pricebook2 testPricebook = TestDataFactory.createTestPricebook();
        TestDataFactory.addProductToPricebook(testSubProduct.Id, Test.getStandardPricebookId());
        PricebookEntry testSubscriptionEntry = TestDataFactory.addProductToPricebook(testSubProduct.Id, testPricebook.Id);
        testAccount = TestDataFactory.createTestAccounts(1, 1, null)[0];
        TestDataFactory.createMerchantIds(testAccount.Id, 2);
        List<Order> testOrders = TestDataFactory.createOrders(new List<Account>{testAccount}, testPricebook.Id);
        
        testSubContract = TestDataFactory.createContract(testAccount.Id, 12, System.today().addMonths(-2));
        testSubContract.SBQQ__Order__c = testOrders[0].Id;

        testRateContract = TestDataFactory.createContract(testAccount.Id, 12, System.today().addMonths(-2));
        testRateContract.SBQQ__Order__c = testOrders[0].Id;
        DAL_BaseObject.InsertDBObjects(new List<Contract>{testSubContract, testRateContract});

        testSubContract.RateContract__c = testRateContract.Id;
        DAL_BaseObject.UpdateDBObject(testSubContract);

        SBQQ__Subscription__c sub1 = TestDataFactory.createSubscription(testAccount.Id, testSubContract.Id, testSubProduct.Id, 
        1, 100, System.today().addMonths(-2), System.today().addMonths(10));
    }

    @isTest
    static void retrieveNoRate()
    {
        setup();

        Test.startTest();

        List<SBQQ__Subscription__c> result = BillingListController.getContractSubscriptions(testSubContract.Id, false);

        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }

    @isTest
    static void retrieveRate()
    {
        setup();

        Test.startTest();

        List<SBQQ__Subscription__c> result = BillingListController.getContractSubscriptions(testRateContract.Id, true);

        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }
}