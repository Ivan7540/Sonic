/*
Date created: 02/06/2021
Developer: Ivan Vrtacnik
JIRA number: PS-225
*/
@isTest(SeeAllData = true)
public class AllContractCancellationInvocableTest 
{
    private static Id testAccountId;

    public static void setup()
    {
        Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'GAU')[0];
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(new List<Account>{testAccount});
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, false);
        List<Id> productIDs = new List<Id> {[Select Id From Product2 Where ProductCode = 'SS_CLASSIC_24_MONTH_BUNDLE'].Id};
            List<PriceBookEntry> pbes = [Select Id,
                                         PriceBook2Id
                                         from PriceBookEntry 
                                         Where PriceBook2.IsStandard = false 
                                         and Product2Id = :productIds[0]];
        Id pricebookId = pbes[0].Pricebook2Id;
        TestDataFactory.addProductToQuote(testQuotes, productIds, pbes[0].Id,'ZAR',true);
        List<Order> testOrders = TestDataFactory.createOrdersForQuote(testQuotes);
        
        for(Order eachOrder : testOrders)
        {
            eachOrder.Status = 'Fulfilled';
            eachOrder.SBQQ__PriceCalcStatus__c = 'Completed';
        }
        
        update testOrders;
        TestDataFactory.contractOrders(testOrders);
    }

    @isTest
    static void testCancellation()
    {
        setup();

        Test.startTest();

        AllContractCancellationInvocable.cancelContracts(new List<Id>{testAccountId});

        Test.stopTest();
    }
}