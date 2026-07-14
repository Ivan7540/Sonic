/**
 * Created by JurgitaG on 4/8/2021.
 */

public with sharing class DTO_QuoteRebate
{
	@AuraEnabled public String productName;
	@AuraEnabled public String quoteId;
	@AuraEnabled public String productCode;
	@AuraEnabled public String productId;
	@AuraEnabled public String device;
	@AuraEnabled public Integer quantity;
	@AuraEnabled public Integer maxQuantity;
	@AuraEnabled public Integer numberOfMonths;
	@AuraEnabled public Decimal rebateAmount;
	@AuraEnabled public Decimal rebatePercentage;

}