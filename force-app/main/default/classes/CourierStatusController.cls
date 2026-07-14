/*
Date created: 04/10/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1025
*/
public class CourierStatusController 
{
    @AuraEnabled
    public static String getWaybillStatus(String waybill)
    {
        return CourierUtil.getShipmentStatus(waybill);
    }
}