@isTest(SeeAllData = true)
public class CPQ_API_AmendContractInv_Test {
    private static Account testAccount;
    private static List<Contract> testContracts;
    private static Id pricebookId;
    private static void setup() {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1,1,'');
        testAccount = testAccounts[0];
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, false);
        List<Id> productIDs = new List<Id> {[Select Id From Product2 Where ProductCode = 'SS_CLASSIC_24_MONTH_BUNDLE'].Id};
            List<PriceBookEntry> pbes = [Select Id,
                                         PriceBook2Id
                                         from PriceBookEntry 
                                         Where PriceBook2.IsStandard = false 
                                         and Product2Id = :productIds[0]];
        pricebookId = pbes[0].Pricebook2Id;
        TestDataFactory.addProductToQuote(testQuotes, productIds, pbes[0].Id,'ZAR',true);
        List<Order> testOrders = TestDataFactory.createOrdersForQuote(testQuotes);
        system.debug('order: ' + testOrders);
        for(Order eachOrder : testOrders)
        {
            eachOrder.Status = 'Fulfilled';
            eachOrder.SBQQ__PriceCalcStatus__c = 'Completed';
        }
        
        update testOrders;
        testContracts = TestDataFactory.contractOrders(testOrders);
    }
    @isTest
    static void testCancellaton(){
        Test.startTest();
        setup();
        Test.stopTest();
        
        CPQ_APIAmendContractInvocable.RequestParams input = new CPQ_APIAmendContractInvocable.RequestParams();
        input.cancelContract = true;
        input.cancellationProductCode = 'SS_CANCELLATION_FEES';
        input.contractId = [Select Id From Contract Where AccountId = :testAccount.Id Limit 1].Id;
        input.priceBookId = pricebookId;
        input.amendStartDate = Date.today();
        CPQ_APIAmendContractInvocable.amendContract(new List<CPQ_APIAmendContractInvocable.RequestParams>{input});
        
    }
}