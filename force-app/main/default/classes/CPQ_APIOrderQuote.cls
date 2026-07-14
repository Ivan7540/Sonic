@RestResource(urlMapping='/SonicCPQ/OrderQuote')
global class CPQ_APIOrderQuote
{
	@HttpPost
	global static DTO_Quote_Response orderQuote()
	{
		String body = RestContext.request.requestBody.toString();
		System.debug(body);
		DTO_Quote aQuoteRequest = (DTO_Quote) System.JSON.deserialize(body, DTO_Quote.class);
		List<SBQQ__Quote__c> quoteInfos = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :aQuoteRequest.quoteId];


		for (SBQQ__Quote__c aQuote :quoteInfos)
		{
			aQuote.SBQQ__Status__c='Orders Created';
		}
		update quoteInfos;
		DTO_Quote aQuoteResponse = new DTO_Quote();
		aQuoteResponse.quoteId = aQuoteRequest.quoteId;
		DTO_Quote_Response aResponse = new DTO_Quote_Response();
		aResponse.id = aQuoteRequest.quoteId;
		aResponse.success = true;
		aResponse.quoteInfo = aQuoteResponse;
		return aResponse;
	}
}