/**
 * Created by JurgitaG on 3/16/2021.
 */

public without sharing class API_Callout_SalesApp extends API_Callout_Base
{
	private static String CPQ_API_ENDPOINT_URL = 'callout:CPQ_Integration';

	private static String FLOWGEAR_ENDPOINT_URL = 'https://adumo.flowgear.net/Salesforce';
	private static String FLOWGEAR_TOKEN = 'c3lzdGVtQHN1cmVzd2lwZS5jby56YTpTeXN0ZW0yMDIw';

	private static String REQUEST_POST_QUOTE ='/services/apexrest/SonicCPQ/CreateQuote';
	private static String REQUEST_GET_QUOTE_SUMMARY ='/services/apexrest/SonicCPQ/CreateQuote';
	private static String REQUEST_POST_DEAL_REBATE ='/services/apexrest/SonicCPQ/DealRebate';
	private static String REQUEST_POST_QUOTE_CALCULATIONS ='/services/apexrest/SonicCPQ/DealRebate';
	private static String REQUEST_POST_CALCULATE_QUOTE ='/services/apexrest/SonicCPQ/CalculateQuote';
	private static String REQUEST_POST_ORDER_QUOTE ='/services/apexrest/SonicCPQ/OrderQuote';
	private static String REQUEST_POST_QUOTE_GROUP = '/services/data/v46.0/sobjects/SBQQ__QuoteLineGroup__c';
	private static String REQUEST_GET_QUOTE = '/services/apexrest/SBQQ/ServiceRouter?reader=SBQQ.QuoteAPI.QuoteReader&uid=';
	private static String REQUEST_PATCH_PRODUCT = '/services/apexrest/SBQQ/ServiceRouter?loader=SBQQ.ProductAPI.ProductLoader&uid=';
	private static String REQUEST_SAVE_QUOTE = '/services/apexrest/SBQQ/ServiceRouter';
	private static String REQUEST_POST_PRODUCT = '/CPQ/AddProduct';

	//create quote
	public Map<String, String> postQuote(DTO_Quote quoteRequest){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_POST_QUOTE);
		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(POST);
		request.setTimeout(120000);

		request.setBody(JSON.serialize(quoteRequest));

		HttpResponse response = new Http().send(request);
		return getRequestResponse(response);
	}
	//get quote summary
	public DTO_QuoteSummary getQuote(String quoteId){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_GET_QUOTE_SUMMARY+'?id='+quoteId);
//		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(GET);
		request.setTimeout(120000);


		HttpResponse response = new Http().send(request);
		System.debug(response.getBody());
		return (DTO_QuoteSummary) System.JSON.deserialize(response.getBody(), DTO_QuoteSummary.class);
	}

	//get quote calculations
	public Map<String, String> postQuoteCalculations(DTO_Quote quoteRequest){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_POST_QUOTE_CALCULATIONS);
		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(POST);
		request.setTimeout(120000);

		request.setBody(JSON.serialize(quoteRequest));

		HttpResponse response = new Http().send(request);
		return getRequestResponse(response);
	}
	//create quote
	public Map<String, String> addRate(DTO_Quote quoteRequest){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_POST_QUOTE);
		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(PATCH);
		request.setTimeout(120000);

		request.setBody(JSON.serialize(quoteRequest));

		HttpResponse response = new Http().send(request);
		return getRequestResponse(response);
	}

	public Map<String, String> addRebates(DTO_Quote quoteRequest){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_POST_DEAL_REBATE);
		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(PATCH);
		request.setTimeout(120000);


		request.setBody(JSON.serialize(quoteRequest));

		HttpResponse response = new Http().send(request);
		return getRequestResponse(response);
	}
	public Map<String, String> submitQuote(List<Id> quoteIds){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_POST_CALCULATE_QUOTE);
		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(POST);
		request.setTimeout(120000);


		request.setBody(JSON.serialize(quoteIds));

		HttpResponse response = new Http().send(request);
		return getRequestResponse(response);
	}

	public Map<String, String> orderQuote(DTO_Quote quoteRequest){
		HttpRequest request = new HttpRequest();

		request.setEndpoint(CPQ_API_ENDPOINT_URL+REQUEST_POST_ORDER_QUOTE);
		request.setHeader(ACCEPT, APPLICATION_JSON);
		request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
		request.setMethod(POST);
		request.setTimeout(120000);

		request.setBody(JSON.serialize(quoteRequest));

		HttpResponse response = new Http().send(request);
		return getRequestResponse(response);
	}

}