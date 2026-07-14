/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest(SeeAllData = true)
private class TEST_CPQ_APIDealRebate
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
		aLine.BundleId__c=CPQ_CreateQuoteModel.createCPQQuoteModel(aQuote.Id, 'QM_QM_ClassicSS_SP_630MonthToMonthMasterpassSwitchPay', null);
		insert aLine;

		aRequest = new DTO_Quote(aOpportunity.Id, aPricebook2.Id, Date.today(),'Draft', null);
		aRequest.saleType='Rental';
		aRequest.dealType='New Business';
		DTO_QuoteProduct quoteProduct = new DTO_QuoteProduct('Classic','SS_SP_630','24Month',1);
		quoteProduct.dealLineId =aLine.Id;
		quoteProduct.staticResourceName ='QM_QM_ClassicSS_SP_630MonthToMonthMasterpassSwitchPay';
		quoteProduct.discount= 15;
		quoteProduct.quantity= 1;
		quoteProduct.numberOfMonths= 1;
		quoteProduct.discountAmount= 0;
		aRequest.products= new List<DTO_QuoteProduct>{quoteProduct};

		aRequest.quoteId = aQuote.Id;
		aRequest.dealId = aDeal.Id;
	}

	@isTest(SeeAllData = true)
	static void testQuoteRebates()
	{
		setup();
		RestRequest request = new RestRequest();
		request.httpMethod = 'PATCH';
		request.requestBody = Blob.valueof(JSON.serialize(aRequest));
		RestContext.request = request;
		DTO_Quote_Response resp = CPQ_APIDealRebate.addRebate();
	}
	@isTest(SeeAllData = true)
	static void testQuoteCalculated()
	{
		setup();
		aRequest.dateSubmitted = Datetime.now();
		RestRequest request = new RestRequest();
		request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(JSON.serialize(aRequest));
		RestContext.request = request;
		DTO_Quote_Response resp = CPQ_APIDealRebate.calculateQuote();
	}
}