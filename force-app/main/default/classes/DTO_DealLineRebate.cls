/**
 * Created by simonas on 2022-02-11.
 */

public virtual class DTO_DealLineRebate
{
	@AuraEnabled public Id id {get; set;}
	@AuraEnabled public String rebateItem {get; set;}
	@AuraEnabled public Decimal rebatedQuantity {get; set;}
	@AuraEnabled public Decimal rebateMonths {get; set;}
	@AuraEnabled public Decimal rebateDiscountPercentage {get; set;}
	@AuraEnabled public Decimal rebateDiscountAmount {get; set;}
	@AuraEnabled public String rebateReason {get; set;}
	@AuraEnabled public String rebateMotivation {get; set;}
	@AuraEnabled public Decimal lineDiscount {get; set;}
	@AuraEnabled public Decimal lineDiscountAmount {get; set;}
}