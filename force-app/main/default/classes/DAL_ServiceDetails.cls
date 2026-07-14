public class DAL_ServiceDetails 
{
    public static Service__mdt getServiceDetails(String serviceName)
    {
        return
        [
            SELECT  Endpoint__c, 
                    Password__c,
                    Username__c,
                    ErrorAddress__c,
                    SendErrorAlerts__c
            FROM Service__mdt
            WHERE DeveloperName = :serviceName
            LIMIT 1
        ];
    }
}