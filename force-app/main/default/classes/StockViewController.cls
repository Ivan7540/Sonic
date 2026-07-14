/*
Date created: 13/09/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1019
*/
public class StockViewController 
{
    @AuraEnabled
    public static List<Stock__c> getAccountStock(Id accountId)
    {
        return
        [
            SELECT  Id,
                    Name,
                    Serial_Number__c,
                    Status__c
            FROM Stock__c
            WHERE Account__c = :accountId
        ];
    }
}