/*
Date created: 29/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-143
*/
@isTest(SeeAllData = false)
public class KeyCloakControllerTest 
{
    private static Contact testContact;

    @TestSetup
    static void setup()
    {
        TestDataFactory.createTestAccounts(1, 3, 'GAU');
        List<Contact> allContacts = getAll();

        Contact existing = allContacts[0];
        existing.External_ID__c = '5b7708f5-2b56-41a0-bcf3-aa3c4dc1edc4';

        Contact flawed = allContacts[1];
        flawed.Email = null;

        DAL_BaseObject.UpdateDBObjects(new List<Contact>{existing, flawed});
    }

    @isTest
    static void testReset()
    {
        testContact = getTestContact(true);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(200));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);
        Test.setCurrentPage(Page.VF_KeyCloakManagement);   

        Test.startTest();

        Pagereference result = ctrl.resetUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();

        System.assertEquals(null, result);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.CONFIRM, pageMessages[0].getSeverity());
        System.assertEquals(ctrl.SUCCESS, pageMessages[0].getSummary());
    }

    @isTest
    static void testResetFail()
    {
        testContact = getTestContact(true);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(400));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);

        Test.startTest();

        Pagereference result = ctrl.resetUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();

        System.assertEquals(null, result);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.FATAL, pageMessages[0].getSeverity());
        System.assertEquals(ctrl.SERVICE_ERROR, pageMessages[0].getSummary());
    }

    @isTest
    static void testResetNotRun()
    {
        testContact = getTestContact(false);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(400));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);

        Test.startTest();

        Pagereference result = ctrl.resetUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();

        System.assertEquals(null, result);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.ERROR, pageMessages[0].getSeverity());
        System.assertEquals(ctrl.RESET_USER_ERROR, pageMessages[0].getSummary());
    }

    @isTest
    static void testResetNotRunEmail()
    {
        testContact = getNoEmailContact();

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(400));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);

        Test.startTest();

        Pagereference result = ctrl.resetUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();

        System.assertEquals(null, result);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.ERROR, pageMessages[0].getSeverity());
        System.assertEquals(ctrl.RESET_EMAIL_ERROR, pageMessages[0].getSummary());
    }

    @isTest
    static void testCreate()
    {
        testContact = getTestContact(false);

        System.assertEquals(null, testContact.External_ID__c);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(200));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);

        Test.startTest();

        Pagereference result = ctrl.createUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        testContact = getById(testContact.Id);

        System.assertEquals(null, result);
        System.assertNotEquals(null, testContact.External_ID__c);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.CONFIRM, pageMessages[0].getSeverity());
        System.assertEquals(ctrl.SUCCESS, pageMessages[0].getSummary());
    }

    @isTest
    static void testCreateFail()
    {
        testContact = getTestContact(false);

        System.assertEquals(null, testContact.External_ID__c);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(400));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);

        Test.startTest();

        Pagereference result = ctrl.createUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        testContact = getById(testContact.Id);

        System.assertEquals(null, result);
        System.assertEquals(null, testContact.External_ID__c);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.FATAL, pageMessages[0].getSeverity());
        System.assertEquals(ctrl.SERVICE_ERROR, pageMessages[0].getSummary());
    }

    @isTest
    static void testCreateNoRun()
    {
        testContact = getNoEmailContact();

        System.assertEquals(null, testContact.External_ID__c);

        Test.setMock(HttpCalloutMock.class, new KeyCloakCalloutMock(200));
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        KeyCloakController ctrl = new KeyCloakController(sc);

        Test.startTest();

        Pagereference result = ctrl.createUser();

        Test.stopTest();

        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        testContact = getById(testContact.Id);

        System.assertEquals(null, result);
        System.assertEquals(null, testContact.External_ID__c);
        System.assertEquals(1, pageMessages.size());
        System.assertEquals(ApexPages.Severity.ERROR, pageMessages[0].getSeverity());
        System.assertEquals(String.format(ctrl.MISSING_FIELD, new String[]{ctrl.EMAIL_FIELD}), pageMessages[0].getSummary());
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

    private static Contact getById(Id contactId)
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
            WHERE Id =:contactId
            LIMIT 1
        ];
    }

    private static Contact getTestContact(Boolean existingUser)
    {
        if(existingUser)
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
                WHERE External_ID__c != null
                AND Email != null
                LIMIT 1
            ];
        }
        else
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
                WHERE External_ID__c = null
                AND Email != null
                LIMIT 1
            ];
        }
    }

    private static Contact getNoEmailContact()
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
                WHERE Email = null
                LIMIT 1
            ];
    }
}