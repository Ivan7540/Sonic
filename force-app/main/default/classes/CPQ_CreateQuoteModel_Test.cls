@isTest
public class CPQ_CreateQuoteModel_Test {
    @isTest(SeeAllData = true)
    static void testCreateQuoteModel() {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, '');        
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, true);
        Test.startTest();
        
        CPQ_CreateQuoteModel.requestParams params = new CPQ_CreateQuoteModel.requestParams();
        
        params.quoteId = testQuotes[0].Id;
        params.staticResource = 'QM_ClassicSS_SP_63024Month';
        params.deviceQtyMap = new Map<String, Integer>{'SS_SP_630' => 2};
        CPQ_CreateQuoteModel.createCPQQuoteModelCallout(new List<CPQ_CreateQuoteModel.requestParams>{params});
        
        params.staticResource = 'QM_ClassicPlusSS_SP_63024Month';
        CPQ_CreateQuoteModel.createCPQQuoteModelCallout(new List<CPQ_CreateQuoteModel.requestParams>{params});
        
        Test.stopTest();
    }
}