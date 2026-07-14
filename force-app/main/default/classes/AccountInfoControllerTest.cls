/*
Date created: 01/07/2021
Developer: Ivan Vrtacnik
JIRA number: PS-772
*/
@isTest(SeeAllData = false)
public class AccountInfoControllerTest 
{
    private static Account testAccount;
    private static Bank_Account__c debitAccount;
    private static Contact primaryContact;
    
    private static void setup()
    {
        testAccount = TestDataFactory.createTestAccounts(1, 1, 'GAU')[0];
        primaryContact = getContact();

        debitAccount = TestDataFactory.createBank(testAccount.Id);
        debitAccount.Type__c = 'Debit Order';
        DAL_BaseObject.InsertDBObject(debitAccount);

        AccountContactRelation primary = getRelation(testAccount.Id);
        primary.Relationship_Strength__c = 'Primary';
        DAL_BaseObject.UpdateDBObject(primary);
    }

    @isTest
    static void testRetrieve()
    {
        setup();

        Test.startTest();

        AccountInfoController.AccountRelatedStruct result = AccountInfoController.getRelated(testAccount.Id);

        Test.stopTest();

        System.assertNotEquals(null, result, 'No value returned');

        System.assertNotEquals(null, result.debitAccountId, 'Debit account not found');
        System.assertNotEquals(null, result.debitAccounts, 'Debit accounts not found');
        System.assertEquals(debitAccount.Id, result.debitAccountId, 'Debit account Id not matching expected value');

        System.assertNotEquals(null, result.primaryContactId, 'Primary Contact not found');
        System.assertNotEquals(null, result.nonPrimaryContacts, 'No Contacts found');
        System.assertEquals(primaryContact.Id, result.primaryContactId, 'Primary Contact Id not matching expected value');
    }

    private static Contact getContact()
    {
        return
        [
            SELECT  Id
            FROM Contact 
            LIMIT 1
        ];
    }

    private static AccountContactRelation getRelation(Id accountId)
    {
        return
        [
            SELECT  Id, 
                    ContactId, 
                    Relationship_Strength__c
            FROM AccountContactRelation
            WHERE AccountId = :accountId
            LIMIT 1
        ];
    }
}