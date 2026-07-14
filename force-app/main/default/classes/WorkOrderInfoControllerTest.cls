/*
Date created: 06/07/2021
Developer: Ivan Vrtacnik
JIRA number: PS-824
*/
@IsTest(SeeAllData = false)
public class WorkOrderInfoControllerTest 
{
    private static Opportunity testOpportunity;
    private static Deal__c testDeal;
    private static WorkOrder__c testWorkOrder;

    private static void setup()
    {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 0, 'GAU');
        testOpportunity = TestDataFactory.createOpportunities(testAccounts)[0];

        testDeal = TestDataFactory.createDeals(1)[0];
        testDeal.Opportunity__c = testOpportunity.Id;
        DAL_BaseObject.UpdateDBObject(testDeal);

        testWorkOrder = TestDataFactory.createWorkOrder(testAccounts[0].Id, null, null, null, 'Installation');
    }

    private static WorkOrder__c getWorkOrder(Id workId)
    {
        return
        [
            SELECT  Id,
                    Deal__c
            FROM WorkOrder__c 
            WHERE Id = :workId 
            LIMIT 1
        ];
    }

    @IsTest
    static void retrieve()
    {
        setup();

        System.assertEquals(null, testWorkOrder.Deal__c, 'Deal already set before method execution, check triggers');

        Test.startTest();

        Id result = WorkOrderInfoController.getDealId(testOpportunity.Id, testWorkOrder.Id);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Id not returned');
        System.assertEquals(testDeal.Id, result, 'Id value returned incorrect');

        testWorkOrder = getWorkOrder(testWorkOrder.Id);

        System.assertNotEquals(null, testWorkOrder.Deal__c, 'Deal not set');
        System.assertEquals(testDeal.Id, testWorkOrder.Deal__c, 'Incorrect Deal set');
    }

    @IsTest
    static void notRetrieve()
    {
        Test.startTest();

        Id result = WorkOrderInfoController.getDealId(null, null);

        Test.stopTest();

        System.assertEquals(null, result, 'Id returned, not expected to');
    }    
}