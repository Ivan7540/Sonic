/**
 * Created by JurgitaG on 11/22/2021.
 */
@IsTest
private class TEST_FLOW_OrderQuote
{
	private static FLOW_OrderQuote.QuoteRequest aRequest;
	static void setup()
	{
		Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];
		Opportunity aOpportunity = TestDataFactory.createOpportunities(new List<Account>{testAccount})[0];
		SBQQ__Quote__c aQuote = TestDataFactory.createQuotes(new List<Opportunity>{aOpportunity}, true)[0];
		aRequest = new FLOW_OrderQuote.QuoteRequest();
		aRequest.QuoteId = aQuote.Id;
	}

	@IsTest
	static void testOrderQuote()
	{
		setup();
		Test.setMock(HttpCalloutMock.class, new CPQ_APIDealMock());

		Test.startTest();
		FLOW_OrderQuote.orderQuote(new List<FLOW_OrderQuote.QuoteRequest>{aRequest});
		List<DTO_QuoteProduct> products = new List<DTO_QuoteProduct>();
		DTO_Quote dtoQ = new DTO_Quote('test', products);
		Test.stopTest();

	}
}