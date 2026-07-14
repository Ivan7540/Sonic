/**
 * Created by JurgitaG on 6/25/2021.
 */

public class DealApprovalInfoController
{
	@AuraEnabled
	public static String getDealId(Id processId)
	{
		List<ProcessInstanceWorkitem> processWorkItems =
		[
				SELECT
						Id, CreatedDate, ProcessInstance.TargetObjectId
				FROM
						ProcessInstanceWorkitem
				WHERE
						Id = :processId
		];
		if (processWorkItems.isEmpty())
		{
			return null;
		}
		return processWorkItems.get(0).ProcessInstance.TargetObjectId;
	}

	@AuraEnabled
	public static List<DTO_QuoteProduct> getDealRates(Id processId)
	{
		Id dealId = getDealId(processId);
		List<DTO_QuoteProduct> dealRates = new List<DTO_QuoteProduct>();
		List<Deal_Line__c> dealLines = [
				SELECT Id, Rate__r.Name, Rate_Percentage__c, TransactionFee__c, CardSplit__c
				FROM Deal_Line__c
				WHERE Deal__c = :dealId AND Rate__c != null
		];
		for (Deal_Line__c aLine : dealLines)
		{
			DTO_QuoteProduct aRate = new DTO_QuoteProduct(null, aLine.Rate__r.Name, aLine.Rate_Percentage__c, aLine.CardSplit__c);
			aRate.dealLineId = aLine.Id;
			aRate.transactionFee = aLine.TransactionFee__c;
			dealRates.add(aRate);
		}
		return dealRates;
	}

	@AuraEnabled
	public static List<DTO_QuoteProduct> getDealRebates(Id processId)
	{
		Id dealId = getDealId(processId);
		List<DTO_QuoteProduct> dealRebates = new List<DTO_QuoteProduct>();
		List<Deal_Line__c> dealLines = [
				SELECT
						Id, RebatedProduct__c,
						RebateItem__c,
						RebateMonths__c,
						RebateDiscountAmount__c,
						RebateDiscountPercentage__c,
						RebatedQuantity__c, Product__c, Device__c
				FROM
						Deal_Line__c
				WHERE
						Deal__c = :dealId
						AND
						(BundleId__c != null OR RebateItem__c != null)];
		for (Deal_Line__c aLine : dealLines)
		{
			DTO_QuoteProduct aRebate = new DTO_QuoteProduct();
			aRebate.product = aLine.Product__c;
			aRebate.dealLineId = aLine.Id;
			aRebate.discountAmount = aLine.RebateDiscountAmount__c;
			aRebate.discount = aLine.RebateDiscountPercentage__c;
			dealRebates.add(aRebate);
		}
		return dealRebates;
	}

	@AuraEnabled
	public static List<DTO_DealLineBundle> getDealBundles(Id processId)
	{
		Id dealId = getDealId(processId);
		List<Deal_Line__c> bundles = new DealLineBundleSelector().findByDealId(dealId);
		List<DTO_DealLineBundle> bundleDto = new DealLineBundleConverter().convert(bundles);
		return bundleDto;
	}
}