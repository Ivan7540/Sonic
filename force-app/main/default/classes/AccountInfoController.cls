/*
Date created: 01/07/2021
Developer: Ivan Vrtacnik
JIRA number: PS-772
*/
public class AccountInfoController 
{
    @AuraEnabled
    public static AccountRelatedStruct getRelated(Id accountId)
    {
        AccountRelatedStruct related = new AccountRelatedStruct(accountId);
        return related;
    }

    public class AccountRelatedStruct
    {
        private Id accountId;
        // If no Contact is designated as primary, 
        // returns a list of all Contacts
        @AuraEnabled
        public Id primaryContactId;
        @AuraEnabled
        public List<Contact> nonPrimaryContacts;

        // If there is morre than one Bank of type "Debit", 
        // returns a list of them. If there is one, returns
        // the single record
        @AuraEnabled
        public Id debitAccountId;
        @AuraEnabled
        public List<Bank_Account__c> debitAccounts;

        public AccountRelatedStruct(Id accountId)
        {
            this.accountId = accountId;

            primaryContactId = getPrimaryContact();
            nonPrimaryContacts = getAllContacts();
            debitAccounts = getDebitAccounts();

            if(debitAccounts.size() == 1)
            {
                debitAccountId = debitAccounts[0].Id;
            }
        }

        private Id getPrimaryContact()
        {
            List<AccountContactRelation> results =
            [
                SELECT ContactId
                FROM AccountContactRelation
                WHERE AccountId = :accountId
                AND Relationship_Strength__c = 'Primary'
            ];

            if(results.size() != 1)
            {
                return null;
            }
            else
            {
                return results[0].ContactId;
            }
        }

        private List<Contact> getAllContacts()
        {
            return
            [
                SELECT Id
                FROM Contact
                WHERE AccountId = :accountId
            ];
        }

        private List<Bank_Account__c> getDebitAccounts()
        {
            return
            [
                SELECT Id
                FROM Bank_Account__c
                WHERE Account__c = :accountId
                AND Type__c = 'Debit Order'
            ];
        }
    }
}