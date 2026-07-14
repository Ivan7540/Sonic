/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class TEST_FLOW_QuoteRate
{
	private static FLOW_QuoteRate.QuoteRateRequest aRequest;
	static void setup()
	{
		Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];
		Opportunity aOpportunity = TestDataFactory.createOpportunities(new List<Account>{testAccount})[0];
		SBQQ__Quote__c aQuote = TestDataFactory.createQuotes(new List<Opportunity>{aOpportunity}, true)[0];
		aRequest = new FLOW_QuoteRate.QuoteRateRequest();
		aRequest.QuoteId =aQuote.Id;
		aRequest.rates = new List<DTO_QuoteProduct>();


	}

	@IsTest
	static void testCreateQuote()
	{
		setup();
		Test.setMock(HttpCalloutMock.class, new CPQ_APIDealMock());

		Test.startTest();
		FLOW_QuoteRate.addRates(new List<FLOW_QuoteRate.QuoteRateRequest>{aRequest});
		Test.stopTest();

	}
}