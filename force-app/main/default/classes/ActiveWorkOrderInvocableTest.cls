/*
Date created: 25/10/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1101
*/
@isTest(SeeAllData = false)
public class ActiveWorkOrderInvocableTest 
{
    private static Id testAssetId;

    private static void setup(Boolean expectedResult)
    {
        Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'GAU')[0];
        testAssetId = TestDataFactory.createAssets(testAccount.Id, 1)[0].Id;

        if(expectedResult)
        {
            WorkOrder__c testWorkOrder = TestDataFactory.createWorkOrder(testAccount.Id, null, null, null);
            WorkOrderLineItem__c line = TestDataFactory.createWorkOrderLine(testWorkOrder.Id, testAssetId, null, null);
            DAL_BaseObject.InsertDBObject(line);
        }        
    }

    @isTest
    static void testPositive()
    {
        setup(false);

        Test.startTest();

        List<Boolean> result = ActiveWorkOrderInvocable.hasActiveWorkOrder(new List<Id>{testAssetId});

        Test.stopTest();

        System.assertEquals(1, result.size(), 'More parameters than expected');
        System.assertEquals(false, result[0], 'Incorrect result, check SOQL filters');
    }

    @isTest
    static void testNegative()
    {
        setup(true);

        Test.startTest();

        List<Boolean> result = ActiveWorkOrderInvocable.hasActiveWorkOrder(new List<Id>{testAssetId});

        Test.stopTest();

        System.assertEquals(1, result.size(), 'More parameters than expected');
        System.assertEquals(true, result[0], 'Incorrect result, check SOQL filters');
    }

    @isTest
    static void testException()
    {
        setup(true);

        Test.startTest();

        try 
        {
            ActiveWorkOrderInvocable.hasActiveWorkOrder(new List<Id>{null});
            System.assert(false, 'Exception should be thrown');
        } 
        catch(ExceptionInvocable.CustomException inEx)
        {
            String message = inEx.getMessage();
            System.assertEquals(ActiveWorkOrderInvocable.missingParamError, message, 'Wrong exception message');
        }
        catch (Exception ex) 
        {
            System.assert(false, 'Wrong type of exception thrown: ' + ex.getTypeName());
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }   
        
        Test.stopTest();
    }

    @isTest
    static void testException2()
    {
        setup(true);

        Test.startTest();

        try 
        {
            ActiveWorkOrderInvocable.hasActiveWorkOrder(new List<Id>{});
            System.assert(false, 'Exception should be thrown');
        } 
        catch(ExceptionInvocable.CustomException inEx)
        {
            String message = inEx.getMessage();
            System.assertEquals(ActiveWorkOrderInvocable.missingParamError, message, 'Wrong exception message');
        }
        catch (Exception ex) 
        {
            System.assert(false, 'Wrong type of exception thrown: ' + ex.getTypeName());
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }   
        
        Test.stopTest();
    }
}