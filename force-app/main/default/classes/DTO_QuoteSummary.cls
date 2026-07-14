/**
 * Created by JurgitaG on 5/6/2021.
 */

global class DTO_QuoteSummary
{
	@AuraEnabled public List<quoteLinesGroup> groups;
	@AuraEnabled public List<quoteLines> rates;
	@AuraEnabled public Decimal onceOffAmount;
	@AuraEnabled public Decimal monthlyAmount;
	

	public class quoteLinesGroup
	{
		@AuraEnabled public String groupName;
		@AuraEnabled public List<quoteLines> quoteLines;
	}

	public class quoteLines
	{
		@AuraEnabled public Id quoteLineId;
		@AuraEnabled public Decimal discount;
		@AuraEnabled public Decimal additionalDiscount;
		@AuraEnabled public Decimal vatAmount;
		@AuraEnabled public Decimal netAmount;
		@AuraEnabled public Decimal netTotal;
		@AuraEnabled public String productName;
		@AuraEnabled public Integer quantity;
		@AuraEnabled public String quoteNumber;
		@AuraEnabled public Decimal rate;
		@AuraEnabled public Decimal transactionFee;
		@AuraEnabled public Decimal lowerBound;
		@AuraEnabled public Decimal upperBound;
		@AuraEnabled public Decimal rebateMonths;
		@AuraEnabled public Decimal rebatePercent;
		@AuraEnabled public Decimal rebateQty;
		@AuraEnabled public Decimal rebateAmount;
	}

}