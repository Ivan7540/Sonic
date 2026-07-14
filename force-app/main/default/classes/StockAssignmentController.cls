/*
Date created: 31/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-567
*/
public class StockAssignmentController 
{
    @AuraEnabled
    public static List<Asset> getWorkOrderAssets(Id accountId, Id orderId)
    {
        return
        [
            SELECT  Id,
                    Name,
                    AssignedStock__c,
                    SerialNumber,
                    Status
            FROM Asset
            WHERE AccountId = :accountId
            AND Order__c = :orderId
            AND Product2.SerialNumberRequired__c = true
        ];
    }
}