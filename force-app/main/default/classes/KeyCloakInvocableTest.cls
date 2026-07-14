@IsTest(SeeAllData = false)
public class KeyCloakInvocableTest 
{
    @isTest
    static void testCreate()
    {
        TestDataFactory.createTestAccounts(1, 1, 'GAU');
        Contact testContact = getAll()[0];

        System.assertEquals(null, testContact.External_ID__c);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(200));

        KeyCloakInvocable.ClientzoneRequest request = new KeyCloakInvocable.ClientzoneRequest();
        request.AccountId = testContact.AccountId; 
        request.DigitalUser = false;

        Test.startTest();
        
        KeyCloakInvocable.createUsers(new List<KeyCloakInvocable.ClientzoneRequest>{request});

        Test.stopTest();

        testContact = getAll()[0];

        System.assertNotEquals(null, testContact.External_ID__c);
    }

    private static List<Contact> getAll()
    {
        return
        [
            SELECT  Id,
                    FirstName,
                    LastName,
                    Email,
                    AccountId,
                    External_ID__c
            FROM Contact
            LIMIT 1000
        ];
    }
}