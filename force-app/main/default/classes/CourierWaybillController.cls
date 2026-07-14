/*
Date created: 29/09/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1025
*/
public class CourierWaybillController 
{
    @TestVisible
    private static final String AccountError = 'Work Order needs to be related to a merchant to retrieve the addresses';
    @TestVisible
    private static final String WorkOrderError = 'Unexpected error. Please notify your admininstrator';
    @TestVisible
    private static final String WorkOrderTypeError = 'Courier service not applicable to this type of Work Order.';

    @AuraEnabled
	public static List<CourierAddressCallout.AddressDetails> getAddresses(Id accountId)
    {
        Account merchant = getAccountDetails(accountId);

        if(merchant == null)
        {
            throw new AuraHandledException(AccountError); 
        }

        List<CourierAddressCallout.AddressDetails> addresses = CourierUtil.getCourierAddresses(merchant.ShippingPostalCode, merchant.ShippingCity);
        return addresses;
    }

    @AuraEnabled
    public static void generateWaybill(Id workOrderId, CourierAddressCallout.AddressDetails suburb)
    {
        String waybill;
        WorkOrder__c originRecord = getWorkOrder(workOrderId);

        if(originRecord == null)
        {
            throw new AuraHandledException(WorkOrderError); 
        }

        switch on originRecord.Type__c 
        {
            when 'Installation' 
            {
                try 
                {
                    waybill = CourierUtil.createInstallationWaybill(suburb, originRecord);
                } 
                catch (Exception ex) 
                {
                    throw new AuraHandledException(ex.getMessage());
                } 
            }
            when 'Collection' 
            {
                try 
                {
                    waybill = CourierUtil.createCollectionWaybill(suburb, originRecord);
                } 
                catch (Exception ex) 
                {
                    throw new AuraHandledException(ex.getMessage());
                }                
            }
            when else 
            {
                throw new AuraHandledException(WorkOrderTypeError); 
            }
        }

        originRecord.LowTouchPartner__c = 'Courier IT';
        originRecord.Waybill_Number__c = waybill;
        originRecord.WaybillTracking__c = CourierUtil.getTrackingLink(waybill);
        DAL_BaseObject.UpdateDBObject(originRecord);
    }

    @AuraEnabled
    public static void generateWaybillOrder(Id orderId, CourierAddressCallout.AddressDetails suburb)
    {
        String waybill;
        Order originRecord = getOrder(orderId);

        if(originRecord == null)
        {
            throw new AuraHandledException(WorkOrderError); 
        }

        try 
        {
            waybill = CourierUtil.createInstallationWaybill(suburb, originRecord);
        } 
        catch (Exception ex) 
        {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }           

        originRecord.Waybill_Number__c = waybill;
        originRecord.WaybillTracking__c = CourierUtil.getTrackingLink(waybill);
        DAL_BaseObject.UpdateDBObject(originRecord);
    }

    private static WorkOrder__c getWorkOrder(Id workOrderId)
    {
        List<WorkOrder__c> results =
        [
            SELECT  Id,
                    Name,
                    Type__c,
                    Account__r.Name,
                    Account__r.ShippingStreet,
                    Contact__r.Name,
                    Contact__r.Phone,
                    Contact__r.MobilePhone,
                    Contact__r.Email,
                    AppointmentDate__c,
                    Description__c
            FROM WorkOrder__c
            WHERE Id = :workOrderId
        ];

        if(results.size() == 1)
        {
            return results[0];
        }
        else
        {
            return null;
        }
    }

    private static Order getOrder(String orderId)
    {
        List<Order> results =
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
                    Description
            FROM Order
            WHERE Id = :orderId
        ];

        if(results.size() == 1)
        {
            return results[0];
        }
        else
        {
            return null;
        }
    }

    private static Account getAccountDetails(Id accountId)
    {
        List<Account> results =
        [
            SELECT  Id,
                    ShippingStreet, 
                    ShippingCity, 
                    ShippingState, 
                    ShippingPostalCode
            FROM Account 
            WHERE Id = :accountId
        ];

        if(results.size() == 1)
        {
            return results[0];
        }
        else
        {
            return null;
        }
    }
}