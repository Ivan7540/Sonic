/*
Date created: 26/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-143
*/
public class KeyCloakController 
{
    public Contact keyCloakUser;
    @TestVisible
    private final String MISSING_FIELD = 'Cannot create a ClientZone user for a Contact with no {0}';
    @TestVisible
    private final String SERVICE_ERROR = 'Service Experienced an Error, Please try again in 1 minute';
    @TestVisible
    private final String RESET_EMAIL_ERROR = 'Cannot reset password for a Contact with no Email';
    @TestVisible
    private final String RESET_USER_ERROR = 'Cannot reset password for a Contact who is not created as a user on ClientZone';
    @TestVisible
    private final String SUCCESS = 'Success';
    @TestVisible
    private final String EMAIL_FIELD = 'Email';
    private final String FIRSTNAME_FIELD = 'First Name';

    public KeyCloakController(ApexPages.StandardController controller)
    {
        this.keyCloakUser = KeyCloakCallout.getContacts(new Set<Id>{controller.getId()})[0];
    }

    public PageReference resetUser() 
    {
        Boolean canRun = true;

        if(String.isEmpty(keyCloakUser.Email))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, RESET_EMAIL_ERROR));           
            canRun = false;
        }
        else if(String.isEmpty(keyCloakUser.External_ID__c))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, RESET_USER_ERROR)); 
            canRun = false;
        }

        if(canRun) 
        {
           Boolean isSuccessful = KeyCloakCallout.resetUser(keyCloakUser.Email);

            if(isSuccessful) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, SUCCESS));
            } 
            else 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, SERVICE_ERROR));
            }  
        }

        return null;
    }

    public PageReference createUser() 
    {
        Boolean canRun = true;

        if(String.isEmpty(keyCloakUser.Email) || String.isEmpty(keyCloakUser.FirstName))
        {
            String missingFieldName = String.isEmpty(keyCloakUser.Email) ? EMAIL_FIELD : FIRSTNAME_FIELD;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, String.format(MISSING_FIELD, new String[]{missingFieldName})));
            canRun = false;
        }        

        if(canRun)
        {
            Boolean isSuccessful = KeyCloakCallout.createUser(
                keyCloakUser.Email,
                keyCloakUser.FirstName,
                keyCloakUser.LastName,
                keyCloakUser.Account,
                keyCloakUser.Id
            );

            if(isSuccessful) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, SUCCESS));
            } 
            else 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, SERVICE_ERROR));
            }
        }        

        return null;
    }
}