/*
Date created: 19/01/2021
Developer: Ivan Vrtacnik
JIRA number: PS-33
*/
public class DAL_Lead 
{
    public static String STATUS_WORKING = 'Working';
    public static String STATUS_NEW = 'New';
    public static String STATUS_CONTACT = 'Contacted';

    public static String SOURCE_WEB = 'Web Query';

    public static Lead getById(Id leadId)
    {
        List<Lead> results =
        [
            SELECT  Id,
                    LeadSource,
                    Status,
                    Escalation_Time__c
            FROM Lead
            WHERE Id = :leadId
        ];

        if(results.size() == 1)
        {
            return results[0];
        }
        else 
        {
           return null; 
        } 
    }
}