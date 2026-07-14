/*
Date created: 25/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-531
*/
@isTest(SeeAllData = true)
public class StockSelectionControllerTest 
{
    private static Account warehouse;
    private static WorkOrder__c testWorkOrder;
    private static Stock__c oldStock1, oldStock2, newStock1, newStock2;
    private static Asset testAsset1, testAsset2;
    private static Id testProdId;

    private static void setup()
    {
        List<Account> accs = TestDataFactory.createTestAccounts(1, 0, 'GAU');
        Account customer = accs[0];

        warehouse = TestDataFactory.createWarehouses(1)[0];

        List<Opportunity> testOpties = TestDataFactory.createOpportunities(accs);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, false);
        List<Id> productIDs = new List<Id> {[Select Id From Product2 Where ProductCode = 'SS_CLASSIC_24_MONTH_BUNDLE'].Id};
        testProdId = productIDs[0];
        List<PriceBookEntry> pbes = [Select Id,
                                         PriceBook2Id
                                         from PriceBookEntry 
                                         Where PriceBook2.IsStandard = false 
                                         and Product2Id = :productIds[0]];
        Id pricebookId = pbes[0].Pricebook2Id;
        TestDataFactory.addProductToQuote(testQuotes, productIds, pbes[0].Id,'ZAR',true);
        List<Order> testOrders = TestDataFactory.createOrdersForQuote(testQuotes);
        
        List<Stock__c> testStock = TestDataFactory.createStock(4, warehouse.Id, testProdId);
        oldStock1 = testStock[0];
        newStock1 = testStock[1];
        oldStock2 = testStock[2];
        newStock2 = testStock[3];

        TestDataFactory.createStock(1, warehouse.Id, testProdId);
        TestDataFactory.createStock(1, null, testProdId);

        List<Asset> allAssets = TestDataFactory.createAssets(customer.Id, 2);
        testAsset1 = allAssets[0];
        testAsset2 = allAssets[1];
        testAsset1.AssignedStock__c = oldStock1.Id;
        testAsset1.Product2Id = testProdId;
        testAsset2.AssignedStock__c = oldStock2.Id;
        testAsset2.Product2Id = testProdId;
        DAL_BaseObject.UpdateDBObjects(new List<Asset>{testAsset1, testAsset2});
        
        testWorkOrder = TestDataFactory.createWorkOrder(customer.Id, null, null, testOrders[0].Id, 'Collection/Installation');

        WorkOrderLineItem__c assetLn1 = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, testAsset1.Id, null, null);
        WorkOrderLineItem__c assetLn2 = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, testAsset2.Id, null, null);
        DAL_BaseObject.InsertDBObjects(new List<WorkOrderLineItem__c>{assetLn1, assetLn2});
    }

    @isTest
    static void testQuery()
    {
        setup();

        Test.startTest();

        List<Stock__c> results = StockSelectionController.getWarehouseStock(warehouse.Id, testWorkOrder.Order__c);

        Test.stopTest();

        //TODO: Fix assetions
        //System.assertEquals(4, results.size(), 'Amount of Stock incorrect');
        //System.assertEquals(results[0].Product__c, results[1].Product__c, 'Stock of wrong product retrieved');
        //System.assertEquals(results[1].Product__c, results[2].Product__c, 'Stock of wrong product retrieved');
        //System.assertEquals(results[2].Product__c, results[3].Product__c, 'Stock of wrong product retrieved');
        //System.assertEquals(testProdId, results[0].Product__c);
    }
    
    @isTest
    static void testAddStock()
    {
        setup();

        Test.startTest();

        Boolean result = StockSelectionController.addStockToOrder(testWorkOrder.Order__c, new List<Stock__c>{newStock1, newStock2});

        Test.stopTest();

        List<WorkOrderLineItem__c> resultLineItems = getWorkOrderLines(testWorkOrder.Id);
        List<WorkOrderLineItem__c> oldLineItems = new List<WorkOrderLineItem__c>(), newLineItems = new List<WorkOrderLineItem__c>();

        System.assertEquals(4, resultLineItems.size(), 'Work Order Line Items not created');

        for(WorkOrderLineItem__c lineItem: resultLineItems)
        {
            if(lineItem.Stock__c != null)
            {
                newLineItems.add(lineItem);
            }
            else if(lineItem.Asset__c != null)
            {
                oldLineItems.add(lineItem);
            }
        }

        System.assertEquals(2, newLineItems.size(), 'Not all items related');
        System.assertEquals(2, oldLineItems.size(), 'Asset Work Order Line Item number changed');

        System.assert(newLineItems[0].ReplacedItem__c == oldLineItems[0].Id || newLineItems[0].ReplacedItem__c == oldLineItems[1].Id, 'Work Order Line Item not selected for replacement');
        System.assert(newLineItems[1].ReplacedItem__c == oldLineItems[0].Id || newLineItems[1].ReplacedItem__c == oldLineItems[1].Id, 'Work Order Line Item not selected for replacement');
    
        List<Stock__c> orderedStock = getOrderStock(testWorkOrder.Order__c);

        System.assertEquals(2, orderedStock.size(), 'Not all Stock ordered');
        System.assert(orderedStock[0].Id == newStock1.Id || orderedStock[0].Id == newStock2.Id, 'Relevant Stock not ordered');
        System.assert(orderedStock[1].Id == newStock1.Id || orderedStock[1].Id == newStock2.Id, 'Relevant Stock not ordered');
    }

    private static List<WorkOrderLineItem__c> getWorkOrderLines(Id workOrderId)
    {
        return
        [
            SELECT  Id,
                    Stock__c,
                    Asset__c,
                    ReplacedItem__c
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__c = :workOrderId
        ];
    }

    private static List<Stock__c> getOrderStock(Id OrderId)
    {
        return
        [
            SELECT Id
            FROM Stock__c
            WHERE Order__c = :OrderId
        ];
    }
}