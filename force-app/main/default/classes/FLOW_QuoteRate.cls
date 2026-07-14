/**
 * Created by JurgitaG on 3/31/2021.
 */

public with sharing class FLOW_QuoteRate
{
	@InvocableMethod(label='Add Rates' category='Quote' Callout=true)
	public static List<QuoteRateResult> addRates(List<QuoteRateRequest> requests)
	{
		List<Id> createdQuoteIds = new List<Id>();
		List<QuoteRateResult> createdQuotes = new List<QuoteRateResult>();

		for(QuoteRateRequest qrequest : requests){

			Id quoteId = qrequest.QuoteId;
			System.debug(quoteId);
			List<DTO_QuoteProduct> quoteRates = qrequest.rates;

			System.debug(quoteRates);
			DTO_Quote quoteRateReq = new DTO_Quote(quoteId, quoteRates);
			quoteRateReq.dealId = qrequest.dealId;

			HttpRequest request = new HttpRequest();
			Map<String, String> responseObj = new API_Callout_SalesApp().addRate(quoteRateReq);
			System.debug(responseObj);

			DTO_Quote_Response  response = DTO_Quote_Response.parse(responseObj.get(API_Callout_Base.SUCCESS));
//			Id quoteId = response.id;

			QuoteRateResult result = new QuoteRateResult();
			result.quoteId = quoteId;
			result.dateSubmitted = response.quoteInfo.dateSubmitted;
			createdQuotes.add(result);
//			Id quoteId = response.id;
			createdQuoteIds.add(quoteId);
			System.debug(quoteId);

		}
		return createdQuotes;
	}
	public class QuoteRateRequest
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String QuoteId;
		@InvocableVariable(label='Deal Id' required=true)
		public String dealId;

		//Because we cannot pass any other type List to Invocable method,
		// I am passing conjunct String where fields is presented in following order: Product, Device, Contract Term, Quantity
		// they are separated by ',' symbol
		@InvocableVariable(label='Product List')
		public List<DTO_QuoteProduct> rates;
	}
	public class QuoteRateResult{
		@InvocableVariable(label='Quote Id' required=true)
		public String quoteId;


		@InvocableVariable(label='Quote submitted for calculation time')
		public Datetime dateSubmitted;
	}

}