/*
Date created: 01/09/2021
Developer: Ivan Vrtacnik
JIRA number: PS-994
*/
public class StockReplacementController 
{
    @AuraEnabled
    public static List<WorkOrderLineItem__c> getWorkOrderLines(Id workOrderId)
    {
        List<WorkOrderLineItem__c> intermediateResult =
        [
            SELECT  Id,
                    Name,
                    Model__c,
                    Asset__c,
                    Asset__r.AssignedStock__c,
                    (SELECT Id FROM StockItems__r)
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__c = :workOrderId
            AND Asset__c != null
        ];

        List<WorkOrderLineItem__c> finalResult = new List<WorkOrderLineItem__c>();

        for (WorkOrderLineItem__c line: intermediateResult) 
        {
            if(line.StockItems__r.size() == 0)
            {
                finalResult.add(line);
            }
        }

        return finalResult;
    }
}