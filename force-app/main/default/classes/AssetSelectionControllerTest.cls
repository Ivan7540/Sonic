/*
Date created: 04/02/2021
Developer: Ivan Vrtacnik
JIRA number: PS-176
*/
@isTest(SeeAllData=false)
public class AssetSelectionControllerTest 
{
    private static Account testAccount;
    private static List<Asset> testAssets;
    private static WorkOrder__c testWorkOrder;

    static void setup()
    {
        TestDataFactory.createTestAccounts(1, 0, 'Gauteng');
        testAccount = DAL_Account.getAll()[0];
        testAssets = TestDataFactory.createAssets(testAccount.Id, 2);
        testWorkOrder = TestDataFactory.createWorkOrder(testAccount.Id, null, null, null);
    }

    private static List<WorkOrderLineItem__c> getAllLines()
    {
        return 
        [
            SELECT  Id,
                    WorkOrder__c,
                    Asset__c
            FROM WorkOrderLineItem__c
        ];
    }

    @isTest
    static void retrieval()
    {
        setup();

        Test.startTest();

        List<Asset> results = AssetSelectionController.getAccountAssets(testAccount.Id);

        Test.stopTest();

        System.assertEquals(2, results.size());

        for(Asset ast :results)
        {
            System.assertEquals(testAccount.Id, ast.AccountId);
        }
    }

    @isTest
    static void creation()
    {
        setup();
        
        Test.startTest();

        // No Assets selected, no Work Order Lines and no exception
        AssetSelectionController.createLineItems(testWorkOrder.Id, new List<Asset>());
        List<WorkOrderLineItem__c> results = getAllLines();
        System.assertEquals(0, results.size());

        // One Asset selected, one Work Order Line created
        AssetSelectionController.createLineItems(testWorkOrder.Id, new List<Asset>{testAssets[0]});
        results = getAllLines();
        System.assertEquals(1, results.size());
        System.assertEquals(testAssets[0].Id, results[0].Asset__c);

        // Same Asset selected again, no new Work Order Lines created
        AssetSelectionController.createLineItems(testWorkOrder.Id, new List<Asset>{testAssets[0]});
        results = getAllLines();
        System.assertEquals(1, results.size());
        System.assertEquals(testAssets[0].Id, results[0].Asset__c);

        // All Assets selected, Work Order Lines created
        AssetSelectionController.createLineItems(testWorkOrder.Id, testAssets);
        results = getAllLines();
        System.assertEquals(2, results.size());
        System.assertNotEquals(results[0].Asset__c, results[1].Asset__c);

        Test.stopTest();
    }
}