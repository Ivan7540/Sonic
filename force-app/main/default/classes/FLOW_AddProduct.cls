/**
 * Created by JurgitaG on 2/18/2021.
 */

public without sharing class FLOW_AddProduct
{
	@InvocableMethod(label='Add Product' category='Product' Callout=true)
	public static List<Id> addProducts(List<AddProductRequest> requests)
	{
		List<Id> createdGroupIds = new List<Id>();

		for(AddProductRequest groupRequest : requests)
		{
			HttpRequest request = new HttpRequest();

			request.setEndpoint('callout:CPQ_Integration/services/apexrest/SBQQ/ServiceRouter?loader=SBQQ.QuoteAPI.QuoteProductAdder');

			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
			gen.writeEndObject();

			String pretty = gen.getAsString();

			System.debug(pretty);
			request.setMethod('PATCH');
			request.setHeader('Accept', 'application/json');
			request.setHeader('Content-Type', 'application/json');

			HttpResponse response = new Http().send(request);
			if (response.getStatusCode() != 201)
			{
				throw new CalloutException(
						'Invalid Status Code: ' + response.getStatusCode() + '\n'
								+ response.getBody());
			}
			System.debug(response.getBody());
			Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			createdGroupIds.add((String) responseObj.get('id'));
		}

		return createdGroupIds;
	}

	public class AddProductRequest
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String quoteId;

		@InvocableVariable(label='Group Id' required=true)
		public String groupId;

	}
}