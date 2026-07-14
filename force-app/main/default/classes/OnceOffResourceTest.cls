@isTest(SeeAllData = false)
public class OnceOffResourceTest 
{
    @isTest
    static void retrieve()
    {
        List<MerchantId__c> allMerchantNumbers = getMerchantNumbers();

        Test.startTest();

        initContext(allMerchantNumbers[0].Name);
        List<OrderItem> results = OnceOffResource.getProds();

        Test.stopTest();
    }

    @TestSetup
    static void setup()
    {
        Product2 testSubProduct = TestDataFactory.createTestSubscriptionProduct();
        Pricebook2 testPricebook = TestDataFactory.createTestPricebook();
        TestDataFactory.addProductToPricebook(testSubProduct.Id, Test.getStandardPricebookId());
        PricebookEntry testSubscriptionEntry = TestDataFactory.addProductToPricebook(testSubProduct.Id, testPricebook.Id);
        Account testAccount = TestDataFactory.createTestAccounts(1, 1, null)[0];
        TestDataFactory.createMerchantIds(testAccount.Id, 2);
        List<Order> testOrders = TestDataFactory.createOrders(new List<Account>{testAccount}, testPricebook.Id);
        Contract testContract = TestDataFactory.createContract(testAccount.Id, 12, System.today().addMonths(-2));
        testContract.SBQQ__Order__c = testOrders[0].Id;
        testContract.Contract_Type__c = 'Move';
        DAL_BaseObject.InsertDBObject(testContract);

        testContract.Status = BillingUtil.ACTIVE_STATUS;
        DAL_BaseObject.UpdateDBObject(testContract);

        SBQQ__Subscription__c sub1 = TestDataFactory.createSubscription(testAccount.Id, testContract.Id, testSubProduct.Id, 
        2, 200, Date.newInstance(2021, 1, 5), Date.newInstance(2021, 12, 15));

        SBQQ__Subscription__c sub2 = TestDataFactory.createRevisedSubscription(testAccount.Id, testContract.Id, testSubProduct.Id, 
        -1, -200, Date.newInstance(2021, 1, 5), Date.newInstance(2021, 12, 15), sub1.Id);

        List<Rebate__c> rebates = TestDataFactory.createRebates(2, sub1.Id);
        DAL_BaseObject.InsertDBObjects(rebates);
    }

    private static void initContext(String parameter)
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/contract/' + parameter; 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
    }

    private static List<MerchantId__c> getMerchantNumbers()
    {
        return
        [
            SELECT Name 
            FROM MerchantId__c
        ];
    }
}