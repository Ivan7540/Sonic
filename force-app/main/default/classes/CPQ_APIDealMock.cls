@IsTest
global class CPQ_APIDealMock implements HttpCalloutMock {
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest req) {

		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		DTO_Quote_Response aResponse = new DTO_Quote_Response();
		DTO_Quote qInfo = new DTO_Quote();
		DTO_QuoteProduct aProduct= new DTO_QuoteProduct();
		qInfo.products=new List<DTO_QuoteProduct>{aProduct};
		SBQQ__Quote__c aQuote = new SBQQ__Quote__c();
		insert aQuote;
		aResponse.id = aQuote.Id;
		aResponse.success = true;
		aResponse.quoteInfo=qInfo;
		res.setBody(JSON.serialize(aResponse));
		res.setStatusCode(200);
		return res;
	}
}