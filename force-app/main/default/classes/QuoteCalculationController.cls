public with sharing class QuoteCalculationController
{
	@AuraEnabled
	public static Boolean checkIfCalculationIsFinished(Id quoteId, Datetime dateSubmitted){

		DTO_Quote quoteRequest = new DTO_Quote();
		quoteRequest.quoteId = quoteId;
		quoteRequest.dateSubmitted = dateSubmitted;


		Map<String, String> responseObj = new API_Callout_SalesApp().postQuoteCalculations(quoteRequest);
		System.debug(responseObj);

		DTO_Quote_Response response = DTO_Quote_Response.parse(responseObj.get(API_Callout_Base.SUCCESS));

		DTO_Quote aQuoteResponse = response.quoteInfo;
		System.debug(quoteId);

		return aQuoteResponse.isCalculated;
	}
}