/*
Date created: 30/11/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1159
*/
public class KeyCloakInvocable 
{
    @InvocableMethod(label='Create User on Clientzone')
    public static void createUsers(List<ClientzoneRequest> requests)
    {
        if(requests.size() != 1)
        {
            return;
        }

        Boolean isDigital = requests[0].DigitalUser == null ? false : requests[0].DigitalUser;

        Set<Id> contactIds = UTIL_System.extractListIds(getContacts(new List<Id>{requests[0].AccountId}));
        KeyCloakCallout.serviceCalloutNew(contactIds, isDigital);               
    }

    private static List<Contact> getContacts(List<Id> accIds)
    {
        return
        [
            SELECT Id
            FROM Contact 
            WHERE AccountId IN :accIds
        ];
    }

    public class ClientzoneRequest
    {
        @InvocableVariable
        public Id AccountId;

        @InvocableVariable
        public Boolean DigitalUser;
    }
}