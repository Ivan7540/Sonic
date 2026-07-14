/*
Date created: 02/02/2021
Developer: Ivan Vrtacnik
JIRA number: PS-176
*/
public class AssetSelectionController 
{
    @AuraEnabled
    public static List<Asset> getAccountAssets(Id accountId)
    {
        return 
        [
            SELECT  Id,
                    AccountId,
                    Name,
                    Status,
                    SerialNumber,
                    Product2Id
            FROM Asset
            WHERE AccountId = :accountId
        ];
    }

    @AuraEnabled
    public static Boolean createLineItems(Id workOrderId, List<Asset> selectedAssets)
    {
        List<WorkOrderLineItem__c> existingItems = getExistingLines(workOrderId, selectedAssets);
        Set<Id> assetsWithLine = UTIL_System.extractListIds(existingItems, WorkOrderLineItem__c.Asset__c.getDescribe().getLocalName());
        List<WorkOrderLineItem__c> newLines = new List<WorkOrderLineItem__c>();

        for(Asset ast: selectedAssets)
        {
            // If Asset already has a Line Item on the relevant Work Order
            // do not duplicate it
            if(!assetsWithLine.contains(ast.Id))
            {
                WorkOrderLineItem__c newLine = new WorkOrderLineItem__c();
                newLine.WorkOrder__c = workOrderId;
                newLine.Asset__c = ast.Id;
                newLines.add(newLine);
            }
        }
        
        if(!newLines.isEmpty())
        {
            DAL_BaseObject.insertDBObjects(newLines);
        }
        
        return true;
    }

    private static List<WorkOrderLineItem__c> getExistingLines(Id workOrderId, List<Asset> selectedAssets)
    {
        return 
        [
            SELECT Id, Asset__c
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__c = :workOrderId
            AND Asset__c IN :selectedAssets
        ];
    }
}