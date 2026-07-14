/*
Date created: 08/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-214
*/
public class BillingListController 
{
    @AuraEnabled
    public static List<SBQQ__Subscription__c> getContractSubscriptions(Id contractId, Boolean isRate)
    {
        if(isRate)
        {
            return
            [
                SELECT  Id,
                        Name,
                        SBQQ__StartDate__c,
                        SBQQ__EndDate__c,
                        SBQQ__Quantity__c,
                        SBQQ__NetPrice__c,
                        TotalPrice__c,
                        ActiveRebate__c,
                        MaximumRebateEndDate__c
                FROM SBQQ__Subscription__c
                WHERE SBQQ__Contract__c = :contractId
                AND SBQQ__TerminatedDate__c = null
            ];
        }
        else 
        {
            return 
            [
                SELECT  Id,
                        Name,
                        SBQQ__StartDate__c,
                        SBQQ__EndDate__c,
                        SBQQ__Quantity__c,
                        SBQQ__NetPrice__c,
                        TotalPrice__c,
                        ActiveRebate__c,
                        MaximumRebateEndDate__c
                FROM SBQQ__Subscription__c
                WHERE SBQQ__Contract__c = :contractId
            ];
        }
    }
}