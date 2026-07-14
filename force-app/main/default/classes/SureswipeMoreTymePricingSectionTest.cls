@isTest
public class SureswipeMoreTymePricingSectionTest {
    
    @IsTest
    static void testPricingSection(){
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, '');
        List<AccountContactRelation> contactRelations = [Select Id,
                                                         Roles
                                                         From AccountContactRelation
                                                         Where AccountId = :testAccounts[0].Id];
        for(AccountContactRelation eachRelation : contactRelations){
            eachRelation.Roles = 'Director';
        }
        update contactRelations;
        
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, true);
        
        //CPQ_CreateQuoteModel.createCPQQuoteModel(testQuotes[0].Id, 'QM_ClassicSS_SP_63024Month', new Map<String, Integer>{'SS_SP_630_RENTAL' => 1});
        CPQ_CreateQuoteModel.createCPQQuoteModel(testQuotes[0].Id, 'QM_RateBundleWithMoreTyme', null);
        
        test.startTest();
        PageReference pageRef = Page.SureswipeMoreTymePricingSection;
        pageRef.getParameters().put('qid', testQuotes[0].Id);
        Test.setCurrentPage(pageRef);
        SureswipeMoreTymePricingSection amController = new SureswipeMoreTymePricingSection();
        Test.stopTest();
    }
}