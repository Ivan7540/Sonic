/*
Date created: 06/07/2021
Developer: Ivan Vrtacnik
JIRA number: PS-824
*/
public class WorkOrderInfoController 
{
    @AuraEnabled
    public static Id getDealId(Id opportunityId, Id workOrderId)
    {
        List<Deal__c> deals = 
        [
            SELECT Id
            FROM Deal__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY CreatedDate DESC
        ];

        if(deals.isEmpty())
        {
            return null;
        }
        else
        {
            WorkOrder__c updatedWorkOrder = new WorkOrder__c();
            updatedWorkOrder.Id = workOrderId;
            updatedWorkOrder.Deal__c = deals[0].Id;
            DAL_BaseObject.UpdateDBObject(updatedWorkOrder);
            
            return deals[0].Id;
        }
    }
}