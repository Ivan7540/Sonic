/**
 * Created by JurgitaG on 2/18/2021.
 */

global without sharing class DTO_Quote
{
	@AuraEnabled public String Opportunity2;	
	@AuraEnabled public String masterContractId;
	@AuraEnabled public Boolean OrderByQuoteLineGroup;
	@AuraEnabled public String OrderBy;
	@AuraEnabled public String PriceBook;
	@AuraEnabled public String PricebookId;
	@AuraEnabled public Boolean Primary;
	@AuraEnabled public Boolean LineItemsGrouped;
	@AuraEnabled public Date StartDate;
	@AuraEnabled public String Status;
	@AuraEnabled public String quoteId;
	@AuraEnabled public String dealId;
	@AuraEnabled public String accountId;
	@AuraEnabled public Datetime dateSubmitted;
	@AuraEnabled public Boolean isCalculated;
	@AuraEnabled public String saleType;
	@AuraEnabled public String dealType;
	@AuraEnabled public String thirdParty;
    @AuraEnabled public String relatedCase;

	@AuraEnabled public Boolean welcomeBoxNeeded;
	@AuraEnabled public List<DTO_QuoteProduct> products;

	public DTO_Quote()
	{
	}

	public DTO_Quote(String opportunityId, String pricebookId, Date startDate, String status, String relatedCase)
	{
		this.Opportunity2 = opportunityId;
		this.OrderByQuoteLineGroup = true;
		this.OrderBy = null;
		this.PriceBook = pricebookId;
		this.PricebookId = pricebookId;
		this.Primary = true;
		this.LineItemsGrouped = true;
		this.StartDate = startDate;
		this.Status = status;
        this.RelatedCase = relatedCase;
	}

	public DTO_Quote(String quoteId, List<DTO_QuoteProduct> products)
	{
		this.quoteId = quoteId;
		this.products = products;
	}

	public static DTO_Quote parse(String json)
	{
		return (DTO_Quote) System.JSON.deserialize(json, DTO_Quote.class);
	}

}