/*
Date created: 15/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-219
*/
@isTest(SeeAllData = false)
public class SubscriptionCalloutTest 
{
    private static Account testAccount;
    private static Product2 testSubProduct;
    private static List<Order> testOrders;
    private static List<MerchantId__c> testMerchantNumbers;

    static void setup()
    {
        testSubProduct = TestDataFactory.createTestSubscriptionProduct();
        Product2 testOnceProduct = TestDataFactory.createTestOnceOffProduct();
        Pricebook2 testPricebook = TestDataFactory.createTestPricebook();
        TestDataFactory.addProductToPricebook(testSubProduct.Id, Test.getStandardPricebookId());
        TestDataFactory.addProductToPricebook(testOnceProduct.Id, Test.getStandardPricebookId());
        PricebookEntry testSubscriptionEntry = TestDataFactory.addProductToPricebook(testSubProduct.Id, testPricebook.Id);
        PricebookEntry testOnceEntry = TestDataFactory.addProductToPricebook(testOnceProduct.Id, testPricebook.Id);
        testAccount = TestDataFactory.createTestAccounts(1, 1, null)[0];
        testMerchantNumbers = TestDataFactory.createMerchantIds(testAccount.Id, 2);
        testOrders = TestDataFactory.createOrders(new List<Account>{testAccount}, testPricebook.Id);
        TestDataFactory.createOnceOffOrderItems(testOrders, testOnceEntry.Id, testOnceProduct.Id);
    }   

    private static void initContext(String parameter)
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/billing/' + parameter; 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
    }

    @isTest
    static void retrieval()
    {
        setup();

        Contract testContract = TestDataFactory.createContract(testAccount.Id, 12, System.today().addMonths(-2));
        testContract.SBQQ__Order__c = testOrders[0].Id;
        DAL_BaseObject.InsertDBObject(testContract);

        SBQQ__Subscription__c sub1 = TestDataFactory.createSubscription(testAccount.Id, testContract.Id, testSubProduct.Id, 
        1, 100, System.today().addMonths(-2), System.today().addMonths(10));

        initContext(testMerchantNumbers[0].Name);

        Test.startTest();

        // Started before start date, ends after end date
        List<BillingUtil.BillingContract> results1 = SubscriptionCallout.getContracts();
        // // Started after start date, ends after end date
        // List<BillingUtil.BillingContract> results2 = SubscriptionCallout.getContracts();
        // // Started after start date, ends before end date
        // List<BillingUtil.BillingContract> results3 = SubscriptionCallout.getContracts();
        // // Started before start date, ends before end date
        // List<BillingUtil.BillingContract> results4 = SubscriptionCallout.getContracts();
        // // Ends before start date
        // List<BillingUtil.BillingContract> results5 = SubscriptionCallout.getContracts();
        // // Starts after end date
        // List<BillingUtil.BillingContract> results6 = SubscriptionCallout.getContracts();

        Test.stopTest();

        // System.assertEquals(1, results1.size());
        // System.assertNotEquals(null, results1[0]);
        // System.assertNotEquals(null, results1[0].contractRecord);
        // System.assertNotEquals(null, results1[0].subscriptionRecords);
        // System.assertEquals(1, results1[0].subscriptionRecords.size());
        // System.assertNotEquals(null, results1[0].merchantRecords);
        // System.assertEquals(2, results1[0].merchantRecords.size());
        // System.assertNotEquals(null, results1[0].onceOffRecords);
        // System.assertEquals(1, results1[0].onceOffRecords.size());

        // System.assertEquals(1, results2.size());
        // System.assertNotEquals(null, results2[0]);
        // System.assertNotEquals(null, results2[0].contractRecord);
        // System.assertNotEquals(null, results2[0].subscriptionRecords);
        // System.assertEquals(1, results2[0].subscriptionRecords.size());
        // System.assertNotEquals(null, results2[0].merchantRecords);
        // System.assertEquals(2, results2[0].merchantRecords.size());
        // System.assertNotEquals(null, results2[0].onceOffRecords);
        // System.assertEquals(1, results2[0].onceOffRecords.size());

        // System.assertEquals(1, results3.size());
        // System.assertNotEquals(null, results3[0]);
        // System.assertNotEquals(null, results3[0].contractRecord);
        // System.assertNotEquals(null, results3[0].subscriptionRecords);
        // System.assertEquals(1, results3[0].subscriptionRecords.size());
        // System.assertNotEquals(null, results3[0].merchantRecords);
        // System.assertEquals(2, results3[0].merchantRecords.size());
        // System.assertEquals(null, results3[0].onceOffRecords);

        // System.assertEquals(1, results4.size());
        // System.assertNotEquals(null, results4[0]);
        // System.assertNotEquals(null, results4[0].contractRecord);
        // System.assertNotEquals(null, results4[0].subscriptionRecords);
        // System.assertEquals(1, results4[0].subscriptionRecords.size());
        // System.assertNotEquals(null, results4[0].merchantRecords);
        // System.assertEquals(2, results4[0].merchantRecords.size());
        // System.assertEquals(null, results4[0].onceOffRecords);

        // System.assertEquals(0, results5.size());
        // System.assertEquals(0, results6.size());
    }
}