/**
 * Created by simonas on 2022-02-11.
 */

public virtual class DTO_DealLineBundle
{
	@AuraEnabled public Id id {get; set;}
	@AuraEnabled public String product {get; set;}
	@AuraEnabled public String device {get; set;}
	@AuraEnabled public String contractTerm {get; set;}
	@AuraEnabled public Decimal Quantity {get; set;}
	@AuraEnabled public String paymentServer {get; set;}
	@AuraEnabled public String deviceType {get; set;}
	@AuraEnabled public String moretymeType {get; set;}
	@AuraEnabled public List<DTO_DealLineRebate> rebateLines {get; set;}
}