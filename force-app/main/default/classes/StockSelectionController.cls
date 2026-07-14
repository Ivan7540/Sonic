/*
Date created: 25/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-531
*/
public class StockSelectionController 
{
    @AuraEnabled
    public static List<Stock__c> getWarehouseStock(Id warehouseId, Id orderId)
    {
        List<OrderItem> orderProducts = 
        [
            SELECT  Id,
                    Product2Id
            FROM OrderItem
            WHERE OrderId = :orderId
        ];

        Set<Id> orderProductIds = UTIL_System.extractListIds(orderProducts, OrderItem.Product2Id.getDescribe().getLocalName());

        return
        [
            SELECT  Id,
                    Order__c,
                    Product__c,
                    Product__r.Name
            FROM Stock__c
            WHERE Account__c = :warehouseId
            AND Product__c IN :orderProductIds
            AND Order__c != :orderId
        ];
    }

    @AuraEnabled
    public static Boolean addStockToOrder(Id orderId, List<Stock__c> selectedStock)
    {
        List<WorkOrderLineItem__c> existingItems = getExistingLines(orderId, selectedStock);
        Set<Id> stockWithLineIds = UTIL_System.extractListIds(existingItems, WorkOrderLineItem__c.Stock__c.getDescribe().getLocalName());
        WorkOrder__c workOrder = getWorkOrder(orderId);
        Map<Id, List<WorkOrderLineItem__c>> assetLinesMap = getAssetLinesMap(workOrder.Id);

        List<WorkOrderLineItem__c> newLines = new List<WorkOrderLineItem__c>();
        Set<Id> assignedAssetLines = new Set<Id>();

        for(Stock__c stock: selectedStock)
        {
            // If Stock already has a Line Item on the relevant Work Order
            // do not duplicate it
            if(!stockWithLineIds.contains(stock.Id))
            {
                WorkOrderLineItem__c newLine = new WorkOrderLineItem__c();
                newLine.WorkOrder__c = workOrder.Id;
                newLine.Stock__c = stock.Id;
                newLines.add(newLine);

                stock.Order__c = orderId;

                List<WorkOrderLineItem__c> assetLines = assetLinesMap.get(stock.Product__c);

                if(assetLines == null)
                {
                    System.debug(LoggingLevel.WARN, String.format('Selected Stock of different model: {0}. For product changes, use amendments.', new String[]{stock.Product__r.Name}));
                }
                else
                {
                    for(WorkOrderLineItem__c lineItem :assetLines)
                    {
                        if(!assignedAssetLines.contains(lineItem.Id))
                        {
                            newLine.ReplacedItem__c = lineItem.Id;
                            assignedAssetLines.add(lineItem.Id);
                            break;
                        }                        
                    }
                }
            }
        }
        
        if(!newLines.isEmpty())
        {
            DAL_BaseObject.updateDBObjects(selectedStock);
            DAL_BaseObject.insertDBObjects(newLines);
        }

        return true;
    }

    private static WorkOrder__c getWorkOrder(Id orderId)
    {
        return
        [
            SELECT Id
            FROM WorkOrder__c
            WHERE Order__c = :orderId
            AND Type__c = 'Collection/Installation'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    private static List<WorkOrderLineItem__c> getExistingLines(Id orderId, List<Stock__c> selectedStock)
    {
        return 
        [
            SELECT Id, Asset__c
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__r.Order__c = :orderId
            AND Stock__c IN :selectedStock
        ];
    }

    private static Map<Id, List<WorkOrderLineItem__c>> getAssetLinesMap(Id workOrderId)
    {
        Map<Id, List<WorkOrderLineItem__c>> resultMap = new Map<Id, List<WorkOrderLineItem__c>>();

        List<WorkOrderLineItem__c> results = 
        [
            SELECT  Id, 
                    Asset__c,
                    Asset__r.Product2Id
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__c = :workOrderId
            AND Asset__c != null
        ];

        for(WorkOrderLineItem__c lineItem :results)
        {
            if(resultMap.containsKey(lineItem.Asset__r.Product2Id))
            {
                resultMap.get(lineItem.Asset__r.Product2Id).add(lineItem);
            }
            else 
            {
                resultMap.put(lineItem.Asset__r.Product2Id, new List<WorkOrderLineItem__c>{lineItem});
            }
        }

        return resultMap;
    }
}