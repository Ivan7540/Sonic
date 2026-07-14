/*
Date created: 31/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-233
*/
public class TransactionListController 
{
    @AuraEnabled
    public static List<Transaction__c> getAccountTransactions(Id accountId)
    {
        return 
        [
            SELECT  Id,
                    Total_Swipe__c,
                    Total_Local_Card_Swipe__c,
                    Total_Foreign_Card_Swipe__c,
                    Period__c
            FROM Transaction__c
            WHERE Account__c = :accountId
        ];
    }
}