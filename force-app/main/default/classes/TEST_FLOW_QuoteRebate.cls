/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class TEST_FLOW_QuoteRebate
{
	private static FLOW_QuoteRebate.QuoteRateRequest aRequest;
	static void setup()
	{
		Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];
		Opportunity aOpportunity = TestDataFactory.createOpportunities(new List<Account>{testAccount})[0];
		SBQQ__Quote__c aQuote = TestDataFactory.createQuotes(new List<Opportunity>{aOpportunity}, true)[0];

		aRequest = new FLOW_QuoteRebate.QuoteRateRequest();
		aRequest.QuoteId =aQuote.Id;
		DTO_QuoteProduct installRebate = new DTO_QuoteProduct();
		installRebate.rebatedProduct='SS_INSTALL_TRAINING_FEE';

		aRequest.rebates = new List<DTO_QuoteProduct>{installRebate};


	}

	@IsTest
	static void testCreateQuote()
	{
		setup();
		Test.setMock(HttpCalloutMock.class, new CPQ_APIDealMock());

		Test.startTest();
		FLOW_QuoteRebate.addRates(new List<FLOW_QuoteRebate.QuoteRateRequest>{aRequest});
		Test.stopTest();

	}
	@IsTest
	static void testDealLineUpdate()
	{
		setup();
		Deal__c aDeal = TestDataFactory.createDeals(1)[0];
		Deal_Line__c aLine = new Deal_Line__c(RebatedProduct__c ='SS_INSTALL_TRAINING_FEE', Deal__c = aDeal.Id);
		insert aLine;
		aRequest.dealId = aDeal.Id;

		Test.setMock(HttpCalloutMock.class, new CPQ_APIDealMock());

		Test.startTest();
		FLOW_QuoteRebate.updateDealLines(aDeal.Id, aRequest.rebates);
		Test.stopTest();

	}

}