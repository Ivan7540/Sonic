/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class TEST_CPQ_APIDealQuote
{
	private static DTO_Quote aRequest;
	static void setup()
	{
		Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];
		Opportunity aOpportunity = TestDataFactory.createOpportunities(new List<Account>{testAccount})[0];
		Pricebook2 aPricebook2 = TestDataFactory.createTestPricebook();
		SBQQ__Quote__c aQuote = TestDataFactory.createQuotes(new List<Opportunity>{aOpportunity}, true)[0];
		Deal__c aDeal = new Deal__c(Name ='test');
		insert aDeal;
		Deal_Line__c aLine = new Deal_Line__c(Product__c ='Classic',Device__c = 'SS_SP_630', ContractTerm__c='24Month', Deal__c = aDeal.Id);
		insert aLine;
		Case c = new Case();
        insert c;
		aRequest = new DTO_Quote(aOpportunity.Id, aPricebook2.Id, Date.today(),'Draft', c.Id);
		aRequest.saleType='Rental';
		aRequest.dealType='New Business';
		aRequest.dealId=aDeal.Id;
		aRequest.quoteId = aQuote.Id;
		DTO_QuoteProduct quoteProduct = new DTO_QuoteProduct('Classic','SS_SP_630','24Month',1);
		quoteProduct.dealLineId =aLine.Id;

		quoteProduct.productCode = 'SS_SP_630';
		quoteProduct.staticResourceName ='QM_QM_ClassicSS_SP_630MonthToMonthMasterpassSwitchPay';
		aRequest.products= new List<DTO_QuoteProduct>{quoteProduct};
	}

	@isTest(SeeAllData = true)
	static void testCreateQuote()
	{
		setup();
		RestRequest request = new RestRequest();
		request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(JSON.serialize(aRequest));
		RestContext.request = request;
		DTO_Quote_Response resp = CPQ_APIDealQuote.createQuote();
	}

	@isTest(SeeAllData = true)
	static void testQuoteRates()
	{
		setup();
		RestRequest request = new RestRequest();
		request.httpMethod = 'PATCH';
		request.requestBody = Blob.valueof(JSON.serialize(aRequest));
		RestContext.request = request;
		DTO_Quote_Response resp = CPQ_APIDealQuote.addRates();
	}

}