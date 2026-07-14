/*
Date created: 25/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-531
*/
global class SetNewStockInvocable 
{
    @InvocableMethod(label = 'Set New Stock' description = 'Sets new Stock on an existing Asset for the Repair type')
    public static void setNewStock(List<Id> workOrderIds)
    {
        List<WorkOrderLineItem__c> assetItemLines = getAssetLines(workOrderIds);
        List<Asset> updatedAssets = new List<Asset>();
        List<Stock__c> updatedStocks = new List<Stock__c>();

        for(WorkOrderLineItem__c lineItem :assetItemLines)
        {
            if(!lineItem.StockItems__r.isEmpty())
            {
                if(lineItem.Asset__r.AssignedStock__c != null)
                {
                    Stock__c oldStock = new Stock__c();
                    oldStock.Id = lineItem.Asset__r.AssignedStock__c;
                    oldStock.Status__c = 'Broken';
                    updatedStocks.add(oldStock);

                    Stock__c newStock = new Stock__c();
                    newStock.Id = lineItem.StockItems__r[0].Stock__c;
                    newStock.Status__c = 'Installed';
                    newStock.Account__c = lineItem.Asset__r.AccountId;
                    updatedStocks.add(newStock);
                }                

                Asset updatedAsset = new Asset();
                updatedAsset.Id = lineItem.Asset__c;
                updatedAsset.AssignedStock__c = lineItem.StockItems__r[0].Stock__c;
                updatedAssets.add(updatedAsset);                
            }            
        }

        if(!updatedAssets.isEmpty())
        {
            DAL_BaseObject.UpdateDBObjects(updatedAssets);
        }
        
        if(!updatedStocks.isEmpty())
        {
            DAL_BaseObject.UpdateDBObjects(updatedStocks);
        }
    }

    private static List<WorkOrderLineItem__c> getAssetLines(List<Id> workOrderIds)
    {
        return
        [
            SELECT  Id,
                    Asset__c,
                    Asset__r.AssignedStock__c,
                    Asset__r.AccountId,
                    (
                        SELECT  Id,
                                Stock__c
                        FROM StockItems__r
                    )
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__c IN :workOrderIds
            AND Asset__c != null
        ];
    }
}