/*
Date created: 31/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-567
*/
@isTest(SeeAllData = false)
public class StockAssignmentControllerTest 
{
    private static Account customerAccount;
    private static Order customerOrder;
    private static Asset unallocated, readyToShip;

    private static void setup()
    {
        Account warehouse = TestDataFactory.createWarehouses(1)[0];
        customerAccount = TestDataFactory.createTestAccounts(1, 1, 'GAU')[0];
        customerOrder = TestDataFactory.createOrders(new List<Account>{customerAccount}, Test.getStandardPricebookId())[0];
        Product2 testSubProduct = TestDataFactory.createTestSubscriptionProduct();
        PricebookEntry testEntry = TestDataFactory.addProductToPricebook(testSubProduct.Id, Test.getStandardPricebookId());
        OrderItem orderProd = TestDataFactory.createOnceOffOrderItems(new List<Order>{customerOrder}, testEntry.Id, testSubProduct.Id)[0];
        
        List<Asset> allAssets = TestDataFactory.createAssets(customerAccount.Id, 2);
        unallocated = allAssets[0];
        readyToShip = allAssets[1];    

        unallocated.SBQQ__OrderProduct__c = orderProd.Id;
        unallocated.Product2Id = testSubProduct.Id;
        
        readyToShip.Product2Id = testSubProduct.Id;
        readyToShip.AssignedStock__c = TestDataFactory.createStock(1, warehouse.Id, testSubProduct.Id)[0].Id;
        readyToShip.SBQQ__OrderProduct__c = orderProd.Id;
        DAL_BaseObject.UpdateDBObjects(new List<Asset>{readyToShip, unallocated});
    }

    @isTest
    static void testQuery()
    {
        setup();

        Test.startTest();

        List<Asset> results = StockAssignmentController.getWorkOrderAssets(customerAccount.Id, customerOrder.Id);

        Test.stopTest();

        System.assertEquals(2, results.size(), 'Wrong number of Assets returned');
    }
}