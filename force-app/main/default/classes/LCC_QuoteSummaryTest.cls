@IsTest
public class LCC_QuoteSummaryTest 
{
    @IsTest(SeeAllData = true)
    static void testSummaryScreen()
    {
        Test.startTest();

        List<Account> testAccounts = TestDataFactory.createTestAccounts(1,1,'');
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, false);
        List<Id> productIDs = new List<Id> {[Select Id From Product2 Where ProductCode = :DAL_Product.sp630PC].Id};
        List<PriceBookEntry> pbes = [Select Id,
                                     PriceBook2Id
                                     from PriceBookEntry 
                                     Where PriceBook2.IsStandard = false 
                                     and Product2Id = :productIds[0]];
        TestDataFactory.addProductToQuote(testQuotes, productIds, pbes[0].Id,'ZAR',true);
        List<Order> testOrders = TestDataFactory.createOrdersForQuote(testQuotes);
        for(Order eachOrder : testOrders){
            eachOrder.Status = 'Fulfilled';
            eachOrder.SBQQ__PriceCalcStatus__c = 'Completed';
        }
        update testOrders;
        List<Contract> testContracts = TestDataFactory.contractOrders(testOrders);

        DTO_QuoteSummary result1 = LCC_QuoteSummary.getQuoteLines(testQuotes[0].Id);
        // DTO_QuoteSummary result2 = LCC_QuoteSummary.getQuoteLines2(testQuotes[0].Id);

        Test.stopTest();        
        
    }
}