/*
Date created: 25/10/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1101
*/
public class ActiveWorkOrderInvocable 
{
    @TestVisible
    private static final String missingParamError = 'Asset Id parameter not specified';

    @InvocableMethod
    public static List<Boolean> hasActiveWorkOrder(List<Id> assetIds)
    {
        if(assetIds.isEmpty() || assetIds[0] == null)
        {
            ExceptionInvocable.throwCustomFlowException(new List<String>{missingParamError});
        }

        List<WorkOrderLineItem__c> activeLines = getActiveLines(assetIds);
        return new List<Boolean>{!activeLines.isEmpty()};
    }

    private static List<WorkOrderLineItem__c> getActiveLines(List<Id> assetIds)
    {
        return
        [
            SELECT Id
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__r.Status__c NOT IN ('Completed', 'Cancelled')
            AND Asset__c IN :assetIds
        ];
    }
}