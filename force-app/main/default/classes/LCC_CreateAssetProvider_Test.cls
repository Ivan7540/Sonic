@isTest(SeeAllData = true)
public with sharing class LCC_CreateAssetProvider_Test {
    @isTest
    static void testMethods() {
        Product2 testProd = [Select Id, NeedsTerminalId__c From Product2 Where ProductCode = 'SS_CLASSIC_24_MONTH_BUNDLE'];
        testProd.NeedsTerminalId__c = true;
        update testProd;
        
        List<Account> accs = TestDataFactory.createTestAccounts(1, 0, 'GAU');
        Account customer = accs[0];
        
        List<Stock__c> testStock = TestDataFactory.createStock(2, null, testProd.Id);
        
        List<Asset> allAssets = TestDataFactory.createAssets(customer.Id, 2);
        Asset testAsset1 = allAssets[0];
        Asset testAsset2 = allAssets[1];
        testAsset1.AssignedStock__c = testStock[0].Id;
        testAsset1.Product2Id = testProd.Id;
        testAsset2.AssignedStock__c = testStock[1].Id;
        testAsset2.Product2Id = testProd.Id;
        DAL_BaseObject.UpdateDBObjects(new List<Asset>{testAsset1, testAsset2});
        TestDataFactory.createMerchantIds(customer.Id, 1);
        
		List<Opportunity> testOpties = TestDataFactory.createOpportunities(accs);        
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, false);
        
        List<PriceBookEntry> pbes = [Select Id,
                                         PriceBook2Id
                                         from PriceBookEntry 
                                         Where PriceBook2.IsStandard = false 
                                         and Product2Id = :testProd.Id];
        Id pricebookId = pbes[0].Pricebook2Id;
        
        TestDataFactory.addProductToQuote(testQuotes, new List<Id>{testProd.Id}, pbes[0].Id,'ZAR',true);
        List<Order> testOrders = TestDataFactory.createOrdersForQuote(testQuotes);
        
        WorkOrder__c testWorkOrder = TestDataFactory.createWorkOrder(customer.Id, null, null, testOrders[0].Id, 'Installation');
        
        WorkOrderLineItem__c assetLn1 = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, testAsset1.Id, null, null);
        WorkOrderLineItem__c assetLn2 = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, testAsset2.Id, null, null);
        DAL_BaseObject.InsertDBObjects(new List<WorkOrderLineItem__c>{assetLn1, assetLn2});
        Test.startTest();
        List<LCC_CreateAssetProvidersController.AssetData> assetData = LCC_CreateAssetProvidersController.createTerminalIds(testWorkOrder.Id);
        LCC_CreateAssetProvidersController.saveTerminals(JSON.serialize(assetData));
        assetData = LCC_CreateAssetProvidersController.createTerminalIds(testWorkOrder.Id);
        test.stopTest();
    }
}