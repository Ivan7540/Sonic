public without sharing class FLOW_CreateQuote
{
	@InvocableMethod(label='Create Quote' category='Quote' Callout=true)
	public static List<Results> createQuote(List<QuoteRequest> requests)
	{
		List<Results> createdQuoteIds = new List<Results>();

		for (QuoteRequest qrequest : requests)
		{
			List<DTO_QuoteProduct> productList = qrequest.quoteProducts;
			DTO_Quote quoteRequest = new DTO_Quote(qrequest.OpportunityId, qrequest.PricebookId, qrequest.startDate, qrequest.status, qrequest.relatedCase);
			quoteRequest.dealId = qrequest.dealId;
			quoteRequest.saleType = qrequest.saleType;
			quoteRequest.dealType = qrequest.dealType;
			quoteRequest.thirdParty = qrequest.thirdParty;
			quoteRequest.masterContractId = qrequest.masterContractId;

			if (String.isnotBlank(qrequest.accountId))
			{
				quoteRequest.accountId = qrequest.accountId;
			}
            
            if(String.isNotBlank(qrequest.relatedCase))
			{
                quoteRequest.relatedCase = qrequest.relatedCase;
            }
			
			quoteRequest.products = productList;
			Map<String, String> responseObj = new API_Callout_SalesApp().postQuote(quoteRequest);

			DTO_Quote_Response response = DTO_Quote_Response.parse(responseObj.get(API_Callout_Base.SUCCESS));
			Id quoteId = response.id;

			DTO_Quote aQuoteResponse = response.quoteInfo;

			Results result = new Results();
			result.quoteId = quoteId;
			result.products = aQuoteResponse.products;

			createdQuoteIds.add(result);
		}

		return createdQuoteIds;
	}

	public class QuoteRequest
	{
		@InvocableVariable(label='Opportunity Id' required=true)
		public String OpportunityId;

		@InvocableVariable(label='Pricebook'required=true)
		public String PricebookId;

		@InvocableVariable(label='Start Date' Required=true)
		public Date startDate;

		@InvocableVariable(label='Status' required=true)
		public String status;

		@InvocableVariable(label='Sale Type')
		public String saleType;

		@InvocableVariable(label='Deal Type')
		public String dealType;

		@InvocableVariable(label='Third Party')
		public String thirdParty;
        
		@InvocableVariable(label='Related Case') // CH: 2021-08-03: Added related case to close once off cases when order is createdand activated (done for paper roll cases)
		public String relatedCase;
        
		//Because we cannot pass any other type List to Invocable method,
		// I am passing conjunct String where fields is presented in following order: Product, Device, Contract Term, Quantity
		// they are separated by ',' symbol
		@InvocableVariable(label='Product List')
		public List<String> products;

		@InvocableVariable(label='Quote Id')
		public String quoteId;

		@InvocableVariable(label='Account Id')
		public String accountId;

		@InvocableVariable(label='Deal Id')//SWW:2021-06-25: Removed required flag, same code is being used to create simple products
		public String dealId;

		@InvocableVariable(label='Quote Products')
		public List<DTO_QuoteProduct> quoteProducts;

		@InvocableVariable(label='Master Contract Id')
		public String masterContractId;
	}

	public class Results
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String quoteId;

		@InvocableVariable(label='Quote Products')
		public List<DTO_QuoteProduct> products;
	}
}