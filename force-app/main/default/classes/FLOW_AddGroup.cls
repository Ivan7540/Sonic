/**
 * Created by JurgitaG on 2/18/2021.
 */

public without sharing class FLOW_AddGroup
{
	@InvocableMethod(label='Create Group' category='Product' Callout=true)
	public static List<Id> createGroup(List<GroupRequest> requests)
	{
//		GroupRequest groupRequest = requests.get(0);
		List<Id> createdGroupIds = new List<Id>();

		for(GroupRequest groupRequest : requests)
		{
			HttpRequest request = new HttpRequest();

			request.setEndpoint('callout:CPQ_Integration/services/data/v46.0/sobjects/SBQQ__QuoteLineGroup__c');

			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
			gen.writeStringField('Name', groupRequest.name);
			gen.writeStringField('CurrencyIsoCode', groupRequest.currencyiso);
			gen.writeStringField('SBQQ__Quote__c', groupRequest.quoteId);
			gen.writeNumberField('SBQQ__CustomerTotal__c', 0.0);
			gen.writeStringField('SBQQ__Description__c', groupRequest.description);

			gen.writeNumberField('SBQQ__ListTotal__c', 0.0);
			gen.writeNumberField('SBQQ__NetTotal__c', 0.0);
			gen.writeNumberField('SBQQ__Number__c', 1.0);

			gen.writeBooleanField('SBQQ__Optional__c', false);
			gen.writeBooleanField('SBQQ__SeparateContract__c', true);

			gen.writeEndObject();

			String pretty = gen.getAsString();

			System.debug(pretty);
			request.setMethod('POST');
			request.setHeader('Accept', 'application/json');
			request.setHeader('Content-Type', 'application/json');
			request.setBody(pretty);

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

	public class GroupRequest
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String quoteId;

		@InvocableVariable(label='Name'required=true)
		public String name;

		@InvocableVariable(label='Currency' Required=true)
		public String currencyiso;

		@InvocableVariable(label='Description' required=true)
		public String description;

	}

}