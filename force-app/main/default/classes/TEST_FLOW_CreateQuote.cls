/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class TEST_FLOW_CreateQuote
{
	private static FLOW_CreateQuote.QuoteRequest aRequest;
	static void setup()
	{
		Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];
		Opportunity aOpportunity = TestDataFactory.createOpportunities(new List<Account>{testAccount})[0];
		aRequest = new FLOW_CreateQuote.QuoteRequest();
		aRequest.OpportunityId = aOpportunity.Id;
		aRequest.dealType='New Business';
		aRequest.saleType='Rental';
		aRequest.PricebookId = '123';
		aRequest.startDate = Date.today();
		aRequest.status = 'Draft';

	}

	@IsTest
	static void testCreateQuote()
	{
		setup();
		Test.setMock(HttpCalloutMock.class, new CPQ_APIDealMock());

		Test.startTest();
		FLOW_CreateQuote.createQuote(new List<FLOW_CreateQuote.QuoteRequest>{aRequest});
        List<DTO_QuoteProduct> products = new List<DTO_QuoteProduct>();
        DTO_Quote dtoQ = new DTO_Quote('test', products);
		Test.stopTest();

	}
}