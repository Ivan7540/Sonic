/*
Date created: 11/10/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1025
*/
@isTest(SeeAllData = false)
public class CourierWaybillControllerTest 
{
    private static WorkOrder__c testWorkOrder;
    private static Order testOrder;
    private static Account testAccount;

    @TestSetup
    private static void setup()
    {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 0, 'GAU');
        testAccount = testAccounts[0];
        TestDataFactory.createOrders(testAccounts, Test.getStandardPricebookId());
        WorkOrder__c install = TestDataFactory.createWorkOrder(testAccount.Id, null, null, null, 'Installation'); 
        install.AppointmentDate__c = Date.today();
        DAL_BaseObject.UpdateDBObject(install);
        TestDataFactory.createWorkOrder(testAccount.Id, null, null, null, 'Collection');   
        TestDataFactory.createWorkOrder(testAccount.Id, null, null, null, 'Repair');      
    }

    private static Account getTestAccount()
    {
        return
        [
            SELECT  Id,
                    ShippingStreet,
                    ShippingCity,
                    ShippingState,
                    ShippingCountry,
                    ShippingPostalCode
            FROM Account 
            LIMIT 1
        ];
    }

    private static WorkOrder__c getTestWorkOrder(String type)
    {
        return
        [
            SELECT  Id, 
                    Waybill_Number__c, 
                    WaybillTracking__c 
            FROM WorkOrder__c
            WHERE Type__c = :type 
            LIMIT 1
        ];
    }

    private static Order getTestOrder()
    {
        return
        [
            SELECT  Id,
                    Type,
                    OrderNumber,
                    Account.Name,
                    Account.ShippingStreet,
                    ShipToContact.Name,
                    ShipToContact.Phone,
                    ShipToContact.MobilePhone,
                    ShipToContact.Email,
                    InstallationDate__c,
                    Description,
                    Waybill_Number__c,
                    WaybillTracking__c
            FROM Order
            LIMIT 1
        ];
    }

    private static CourierAddressCallout.AddressDetails createAddress()
    {
        CourierAddressCallout.AddressDetails suburb = new CourierAddressCallout.AddressDetails();
        suburb.CityName = 'MIDRAND';
        suburb.SubId = '38433';
        suburb.SuburbName = 'WILLAWAY';
        suburb.BoxCode = '1684';        
        suburb.AgentHub = 'JNB';
        suburb.StreetCode = '1684';
        suburb.HighRisk = 'false';
        suburb.Township = 'false';
        suburb.Surcharge = 'false';

        return suburb;
    }

    @isTest
    static void addresses()
    {                
        testAccount = getTestAccount();

        Test.startTest();

        List<CourierAddressCallout.AddressDetails> results = CourierWaybillController.getAddresses(testAccount.Id);

        Test.stopTest();

        System.assertEquals(1, results.size());
    }

    @isTest
    static void installation()
    {                
        testAccount = getTestAccount();
        testWorkOrder = getTestWorkOrder('Installation');

        System.assert(String.isEmpty(testWorkOrder.Waybill_Number__c), 'Waybill populated before test start');
        System.assert(String.isEmpty(testWorkOrder.WaybillTracking__c), 'Waybill populated before test start');

        CourierAddressCallout.AddressDetails suburb = createAddress();

        Test.startTest();

        CourierWaybillController.generateWaybill(testWorkOrder.Id, suburb);

        Test.stopTest();  
        
        testWorkOrder = getTestWorkOrder('Installation');

        System.assertNotEquals(null, testWorkOrder.Waybill_Number__c, 'Waybill not set');
        System.assertNotEquals(null, testWorkOrder.WaybillTracking__c, 'Waybill not set');
    }

    @isTest
    static void installationOrder()
    {                
        testAccount = getTestAccount();
        testOrder = getTestOrder();

        System.assert(String.isEmpty(testOrder.Waybill_Number__c), 'Waybill populated before test start');
        System.assert(String.isEmpty(testOrder.WaybillTracking__c), 'Waybill populated before test start');

        CourierAddressCallout.AddressDetails suburb = createAddress();

        Test.startTest();

        CourierWaybillController.generateWaybillOrder(testOrder.Id, suburb);

        Test.stopTest();  
        
        testOrder = getTestOrder();

        System.assertNotEquals(null, testOrder.Waybill_Number__c, 'Waybill not set');
        System.assertNotEquals(null, testOrder.WaybillTracking__c, 'Waybill not set');
    }

    @isTest
    static void collection()
    {                
        testAccount = getTestAccount();
        testWorkOrder = getTestWorkOrder('Collection');

        System.assert(String.isEmpty(testWorkOrder.Waybill_Number__c), 'Waybill populated before test start');
        System.assert(String.isEmpty(testWorkOrder.WaybillTracking__c), 'Waybill populated before test start');

        CourierAddressCallout.AddressDetails suburb = createAddress();

        Test.startTest();

        CourierWaybillController.generateWaybill(testWorkOrder.Id, suburb);

        Test.stopTest();  
        
        testWorkOrder = getTestWorkOrder('Collection');

        System.assertNotEquals(null, testWorkOrder.Waybill_Number__c, 'Waybill not set');
        System.assertNotEquals(null, testWorkOrder.WaybillTracking__c, 'Waybill not set');
    }

    @isTest
    static void testExceptions()
    {
        testWorkOrder = getTestWorkOrder('Repair');

        try 
        {
            CourierWaybillController.getAddresses(null);
            System.assert(false, 'Exception should be thrown');
        } 
        catch (Exception ex) 
        {
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'Wrong exception type');
        }

        try 
        {
            CourierWaybillController.generateWaybill(null, createAddress());
            System.assert(false, 'Exception should be thrown');
        } 
        catch (Exception ex) 
        {
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'Wrong exception type');
        }

        try 
        {
            CourierWaybillController.generateWaybill(testWorkOrder.Id, createAddress());
            System.assert(false, 'Exception should be thrown');
        } 
        catch (Exception ex) 
        {
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'Wrong exception type');
        }
    }
}