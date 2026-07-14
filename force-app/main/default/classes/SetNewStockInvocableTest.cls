/*
Date created: 25/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-531
*/
@IsTest(SeeAllData = false)
public class SetNewStockInvocableTest 
{
    private static WorkOrder__c testWorkOrder;
    private static Stock__c oldStock;
    private static Stock__c newStock;
    private static Asset testAsset;

    private static void setup()
    {
        Product2 testProd = TestDataFactory.createTestSubscriptionProduct();
        List<Account> allAccs = TestDataFactory.createTestAccounts(2, 0, 'GAU');
        Account customer = allAccs[0];

        Account warehouse = allAccs[1];
        warehouse.Type = 'Warehouse';
        DAL_BaseObject.UpdateDBObject(warehouse);

        List<Stock__c> testStock = TestDataFactory.createStock(2, warehouse.Id, testProd.Id);
        oldStock = testStock[0];
        newStock = testStock[1];

        testAsset = TestDataFactory.createAssets(customer.Id, 1)[0];
        testAsset.AssignedStock__c = oldStock.Id;
        testAsset.Product2Id = testProd.Id;
        DAL_BaseObject.UpdateDBObject(testAsset);

        testWorkOrder = TestDataFactory.createWorkOrder(customer.Id, null, null, null);

        WorkOrderLineItem__c oldLine = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, testAsset.Id, null, null);
        DAL_BaseObject.InsertDBObject(oldLine);
        WorkOrderLineItem__c newLine = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, null, newStock.Id, oldLine.Id);
        DAL_BaseObject.InsertDBObject(newLine);
    }

    @isTest
    static void setNewStock()
    {
        setup();

        System.assertEquals(oldStock.Id, testAsset.AssignedStock__c, 'Wrong Stock assigned to Asset at start of test');

        Test.startTest();

        SetNewStockInvocable.setNewStock(new List<Id>{testWorkOrder.Id});

        Test.stopTest();

        testAsset = getAsset(testAsset.Id);
        oldStock = getStock(oldStock.Id);
        newStock = getStock(newStock.Id);
        
        System.assertNotEquals(oldStock.Id, testAsset.AssignedStock__c, 'Stock not reassigned');
        System.assertEquals('Broken', oldStock.Status__c, 'Old Stock not broken');
        System.assertEquals(newStock.Id, testAsset.AssignedStock__c, 'Wrong Stock assigned');
        System.assertEquals('Installed', newStock.Status__c, 'New Stock not installed');
        System.assertEquals(testAsset.AccountId, newStock.Account__c, 'New Stock not transferred to merchant');
    }

    private static Asset getAsset(Id assetId)
    {
        return
        [
            SELECT  Id,
                    AssignedStock__c,
                    AccountId
            FROM Asset
            WHERE Id = :assetId
        ];
    }

    private static Stock__c getStock(Id stockId)
    {
        return
        [
            SELECT  Id,
                    Status__c,
                    Account__c
            FROM Stock__c
            WHERE Id = :stockId
        ];
    }
}