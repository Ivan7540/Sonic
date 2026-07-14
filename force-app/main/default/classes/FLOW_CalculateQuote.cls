/**
 * Created by JurgitaG on 9/29/2021.
 */

public class FLOW_CalculateQuote
{
	@InvocableMethod(label='Submit Quote for Calculation' category='Quote' Callout=true)
	public static List<Id> calculateQuote(List<QuoteRateRequest> requests)
	{
		List<Id> quoteIds = new List<Id>();
		for (QuoteRateRequest qrequest : requests)
		{
			Id quoteId = qrequest.QuoteId;
			System.debug(quoteId);
			quoteIds.add(quoteId);
		}
		Map<String, String> responseObj = new API_Callout_SalesApp().submitQuote(quoteIds);

		return quoteIds;
	}
	public class QuoteRateRequest
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String QuoteId;

	}
}