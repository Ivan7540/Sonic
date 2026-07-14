public with sharing class FLOW_OrderQuote
{
	@InvocableMethod(label='Order Quote' category='Quote' Callout=true)
	public static List<Id> orderQuote(List<QuoteRequest> requests)
	{
		List<Id> quoteIds = new List<Id>();
		for (QuoteRequest qrequest : requests)
		{
			Id quoteId = qrequest.QuoteId;
			quoteIds.add(quoteId);
			DTO_Quote quoteRequest = new DTO_Quote();
			quoteRequest.quoteId = quoteId;
			Map<String, String> responseObj = new API_Callout_SalesApp().orderQuote(quoteRequest);
		}
		return quoteIds;
	}
	public class QuoteRequest
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String QuoteId;

	}
}