/*
Date created: 22/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-358
*/
@isTest(SeeAllData = false)
public class GiftContractResourceTest 
{
    @TestSetup
    static void setup()
    {
        Integer thisYear = System.today().year();

        Product2 testSubProduct = TestDataFactory.createTestSubscriptionProduct();
        Pricebook2 testPricebook = TestDataFactory.createTestPricebook();
        TestDataFactory.addProductToPricebook(testSubProduct.Id, Test.getStandardPricebookId());
        PricebookEntry testSubscriptionEntry = TestDataFactory.addProductToPricebook(testSubProduct.Id, testPricebook.Id);
        Account testAccount = TestDataFactory.createTestAccounts(1, 1, null)[0];
        TestDataFactory.createMerchantIds(testAccount.Id, 2);
        List<Order> testOrders = TestDataFactory.createOrders(new List<Account>{testAccount}, testPricebook.Id);
        Contract testContract = TestDataFactory.createContract(testAccount.Id, 12, System.today().addMonths(-2));
        testContract.SBQQ__Order__c = testOrders[0].Id;
        testContract.ContractType__c = BillingUtil.GIFT_LOYALTY_TYPE;
        testContract.InstallationDate__c = System.today().addMonths(-9);
        DAL_BaseObject.InsertDBObject(testContract);

        testContract.Status = BillingUtil.ACTIVE_STATUS;
        DAL_BaseObject.UpdateDBObject(testContract);

        SBQQ__Subscription__c sub1 = TestDataFactory.createSubscription(testAccount.Id, testContract.Id, testSubProduct.Id, 
        2, 200, Date.newInstance(thisYear, 1, 5), Date.newInstance(thisYear, 12, 15));

        SBQQ__Subscription__c sub2 = TestDataFactory.createRevisedSubscription(testAccount.Id, testContract.Id, testSubProduct.Id, 
        -1, -200, Date.newInstance(thisYear, 1, 5), Date.newInstance(thisYear, 12, 15), sub1.Id);

        List<Rebate__c> rebates = TestDataFactory.createRebates(2, sub1.Id);
        DAL_BaseObject.InsertDBObjects(rebates);
    }

    @isTest
    static void retrieve()
    {
        Test.startTest();
        
        initContext(dateParamFormat(), '0', '1000');
        List<BillingUtil.BillingContract> results = GiftContractResource.getGiftContracts();

        Test.stopTest();

        System.assertEquals(1, results.size());
        BillingUtil.BillingContract result = results[0];
        System.assertEquals(1, result.subscriptionRecords.size());
        SBQQ__Subscription__c resultingSubscription = result.subscriptionRecords[0];
        System.assertEquals(2, resultingSubscription.SBQQ__Quantity__c);
        System.assertEquals(400, resultingSubscription.SBQQ__NetPrice__c);
    }

    // TODO: provide coverage for exceptions
    /*
    @isTest
    static void exception()
    {
        Test.startTest();

        try 
        {
            initContext('2021/02/12', '0', '1000');
            GiftContractResource.getGiftContracts();
            System.assert(false, 'Exception should be thrown');
        }
        catch (Exception ex) 
        {
            System.assert(ex.getMessage().contains('Parameter passed cannot be parsed to a valid date'), 'Incorrect Exception');
        }   
        
        Test.stopTest();
    }
    */

    private static void initContext(String dateParam, String offsetParam, String limitParam)
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.params.put(BillingUtil.DATE_PARAM, dateParam);
        req.params.put(BillingUtil.OFFSET_PARAM, offsetParam);
        req.params.put(BillingUtil.LIMIT_PARAM, limitParam); 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
    }

    private static String dateParamFormat()
    {
        String template = '{0}-{1}-{2}';
        String[] args = new String[]{};
        Date today = Date.today();

        args.add(String.valueOf(today.year()));
        args.add(String.valueOf(today.month()));
        args.add(String.valueOf(today.day()));

        return String.format(template, args);
    }
}