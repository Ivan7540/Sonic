/**
 * Created by JurgitaG on 3/31/2021.
 */

public with sharing class DTO_QuoteRate
{
	@AuraEnabled public String quoteId;
	@AuraEnabled public String rateProduct;
	@AuraEnabled public Decimal ratePercentage;
	public DTO_QuoteRate(String quoteId){
		this.quoteId = quoteId;
	}
	public DTO_QuoteRate(){
	}

}