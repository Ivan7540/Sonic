/**
* Author	:	Swapnil Walse
* Date		:	15 March 2021
* Desc		:	Test class for CPQ Apis. Products need to be created first in the 
*			:	destination org before running these tests.
* 			:	
* 			:	 
* 				
**/

@IsTest
public class CPQ_ApiWrapperTest {
    
    @IsTest
    static void testGetQuoteModel() {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, '');        
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, true);
        SBQQ__Quote__c quote = [Select Id FROM SBQQ__Quote__c Order By CreatedDate Desc LIMIT 1];
        QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(quote.Id);
    }
    
    @IsTest(SeeAllData = true)//Need to read products so setting SeeAllData = true
    static void testLoadProduct() {
        
        Product2 product = [Select Id, Name From Product2 Where ProductCode = 'SS_RATE_BUNDLE'];
        List<PriceBookEntry> pbes = [Select Id, PriceBook2Id, Product2Id From PriceBookEntry Where Product2Id = :product.Id];
        Test.startTest();
        ProductModel productModel = CPQ_ApiWrapper.loadProduct(product.Id, pbes[0].Id, 'ZAR');
        Test.stopTest();
    }
    
    
    @IsTest(SeeAllData = true)
    static void testAddProductToQuoteAndSaveQuote() {
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, '');        
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, true);
        Product2 product = [Select Id, Name From Product2 Where ProductCode = 'SS_RATE_BUNDLE'];
        List<PriceBookEntry> pbes = [Select Id, PriceBook2Id, Product2Id From PriceBookEntry Where Product2Id = :product.Id];
        Test.startTest();
        QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(testQuotes[0].Id);
        quoteModel = CPQ_ApiWrapper.addProductsToQuote(quoteModel, new List<Id>{product.Id}, pbes[0].id, 'ZAR', true);
        
        CPQ_ApiWrapper.saveQuote(quoteModel);
        CPQ_ApiWrapper.calculateQuote(testQuotes[0].Id);
        CPQ_APICalculateQuoteCallout.calculateQuote(new List<Id>{testQuotes[0].Id});
        CPQ_APICalculateQuoteInvocable.calculateQuote(new List<Id>{testQuotes[0].Id});
        Test.stopTest();
        
    }
    
    @IsTest(SeeAllData=true)
    static void testAmendContract() {

        List<Account> testAccounts = TestDataFactory.createTestAccounts(1,1,'');
       
        Contract contract = TestDataFactory.createContract(testAccounts[0].Id, 12, Date.today());
        insert contract;
        //contract.Status = 'Activated';
        //update contract;
        
        Test.startTest();
        
        QuoteModel quoteModel = CPQ_ApiWrapper.amendContract(contract.Id);
        //List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c];
        Test.stopTest();
        //System.assertNotEquals(null, quoteModel);
        //System.assertEquals(2, quotes.size());
    }
    @IsTest(SeeAllData = true)
    static void testGenerateDocument(){
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, '');        
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, true);
        Test.startTest();
        CPQ_APIGenerateQuoteDocumentCallout.requestParams param = new CPQ_APIGenerateQuoteDocumentCallout.requestParams();
        param.quoteId = testQuotes[0].Id;
        CPQ_APIWrapper.generateQuoteProposal(testQuotes[0].Id, 'testDocument', null, null, 'a1525000001Kv0iAAC', null);
        CPQ_APIGenerateQuoteDocumentCallout.generateQuoteDocument(new List<CPQ_APIGenerateQuoteDocumentCallout.requestParams>{param});
        Test.stopTest();
    }
}