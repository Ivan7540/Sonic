@isTest(SeeAllData = false)
public class OpportunityTriggerHandlerTest 
{
    @TestSetup
    static void setup()
    {
        List<Account> acc = TestDataFactory.createTestAccounts(1, 1, 'GAU');
        acc[0].RegistrationNumber__c = '1215';
        acc[0].BillingStreet = 'test';
        acc[0].BillingCity = 'Bangluru';
        acc[0].BillingPostalCode = '597844';
        acc[0].ShippingStreet = 'test';
        acc[0].ShippingCity = 'Bangluru';
        acc[0].ShippingPostalCode = '121545';
        acc[0].Phone = '9876543210';
        List<Contact> allContacts = getAll();

        Pricebook2 pb = TestDataFactory.createTestPricebook();
        Contract contr = TestDataFactory.createContract(acc[0].Id,2,date.ValueOf('2021-06-05'));
        contr.CustomerSignedId = allContacts[0].Id;
        insert contr;
        Contact contLst = getById(contr.CustomerSignedId);
        List<Opportunity> opp = TestDataFactory.createOpportunities(acc,pb.Id);
        system.debug('contr.Id123 == '+contr.Id);
    }
        
    static testmethod void getAbilityDebtorNewTest() 
    {
        List<Account> acc = TestDataFactory.createTestAccounts(1, 3, 'GAU');
        acc[0].RegistrationNumber__c = '1215';
        acc[0].BillingStreet = 'test';
        acc[0].BillingCity = 'Bangluru';
        acc[0].BillingPostalCode = '597844';
        acc[0].ShippingStreet = 'test';
        acc[0].ShippingCity = 'Bangluru';
        acc[0].ShippingPostalCode = '121545';
        acc[0].Phone = '9876543210';
        List<Contact> allContacts = getAll();
        Pricebook2 pb = TestDataFactory.createTestPricebook();
        Contract contr = TestDataFactory.createContract(acc[0].Id,2,date.ValueOf('2021-06-05'));
        contr.CustomerSignedId = allContacts[0].Id;
        insert contr;
        Contact contLst = getById(contr.CustomerSignedId);
        List<Opportunity> opp = TestDataFactory.createOpportunities(acc,pb.Id);
        //opp[0].ContractId = contr.Id;
        //opp[0].StageName ='Contract Completed/Won';
        Test.startTest();
        update opp;
        //Test.setMock(HttpCalloutMock.class, new getAbilityDebtorMock(200));
		Contact Contacts1 = getById(allContacts[0].Id);
        system.debug('Contacts1 == '+Contacts1);
        Test.stopTest();
    }
    
    static testmethod void updateDealTest() 
    {
        List<Account> acc = TestDataFactory.createTestAccounts(1, 3, 'GAU');   
        acc[0].RegistrationNumber__c = '1215';
        acc[0].BillingStreet = 'test';
        acc[0].BillingCity = 'Bangluru';
        acc[0].BillingPostalCode = '597844';
        acc[0].ShippingStreet = 'test';
        acc[0].ShippingCity = 'Bangluru';
        acc[0].ShippingPostalCode = '121545';
        acc[0].Phone = '9876543210';     
        Pricebook2 pb = TestDataFactory.createTestPricebook();
        system.debug('pb == '+pb);
        List<Opportunity> opp = TestDataFactory.createOpportunities(acc,pb.Id);
        opp[0].DocumentCheckStatus__c = 'OFAC Rejected';
        system.debug('opp == '+opp);
        List<Deal__c> deal = TestDataFactory.createDeals(3);
        system.debug('deal == '+deal);
        deal[0].DocumentCheck__c = 'FICA Submitted';
        deal[1].DocumentCheck__c = 'FICA Submitted';
        deal[2].DocumentCheck__c = 'FICA Submitted';
        deal[0].Opportunity__c = opp[0].Id;
        deal[1].Opportunity__c = opp[0].Id;
        deal[2].Opportunity__c = opp[0].Id;
        update deal;
        system.debug('deal == '+deal);
        Test.startTest();

        update opp;
        Test.stopTest();
        system.debug(' deal == '+deal);
    }
    
    private static List<Contract> getAllContract()
    {
        return
        [
            SELECT  Id,
                    AccountId
            FROM Contract
            LIMIT 1000
        ];
    }
    
    private static List<Opportunity> getAllOpportunity()
    {
        return
        [
            SELECT  Id,
                    AccountId
            FROM Opportunity
            LIMIT 1000
        ];
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
                    KeyCloakIdentifier__c,
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
                    KeyCloakIdentifier__c,
                    External_ID__c
            FROM Contact
            WHERE Id =:contactId
            LIMIT 1
        ];
    }
}