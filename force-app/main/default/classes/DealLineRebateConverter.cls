/**
 * Created by simonas on 2022-02-11.
 */

public virtual class DealLineRebateConverter
{
	public List<DTO_DealLineRebate> convert(List<Deal_Line__c> dealLines)
	{
		List<DTO_DealLineRebate> rebates = new List<DTO_DealLineRebate>();
		for (Deal_Line__c dealLine : dealLines)
		{
			DTO_DealLineRebate rebate = new DTO_DealLineRebate();
			rebate.rebateItem = dealLine.RebateItem__c;
			rebate.rebatedQuantity = dealLine.RebatedQuantity__c;
			rebate.rebateMonths = dealLine.RebateMonths__c;
			rebate.rebateDiscountPercentage = dealLine.RebateDiscountPercentage__c == null ? null : dealLine.RebateDiscountPercentage__c / 100;
			rebate.rebateDiscountAmount = dealLine.RebateDiscountAmount__c;
			rebate.rebateReason = dealLine.RebateReason__c;
			rebate.rebateMotivation = dealLine.RebateMotivation__c;
			rebate.lineDiscount = dealLine.LineDiscount__c == null ? null : dealLine.LineDiscount__c / 100;
			rebate.lineDiscountAmount = dealLine.LineDiscountAmount__c;
			rebates.add(rebate);
		}
		return rebates;
	}
}