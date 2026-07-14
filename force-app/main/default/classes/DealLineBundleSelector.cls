/**
 * Created by simonas on 2022-02-11.
 */

public virtual without sharing class DealLineBundleSelector
{
	public List<Deal_Line__c> findByDealId(Id dealId)
	{
		return this.findByDealIds(new Set<Id> {dealId});
	}

	public List<Deal_Line__c> findByDealIds(Set<Id> dealIds)
	{
		return [
				SELECT
						Id,
						Product__c,
						Device__c,
						ContractTerm__c,
						Quantity__c,
						PaymentServer__c,
						DeviceType__c,
						MoretymeType__c,
				(
						SELECT
								Id,
								RebateItem__c,
								RebatedQuantity__c,
								RebateMonths__c,
								RebateDiscountPercentage__c,
								RebateDiscountAmount__c,
								RebateReason__c,
								RebateMotivation__c,
								LineDiscount__c,
								LineDiscountAmount__c
						FROM
								Child_Lines__r
						WHERE RebateItem__c != null
				)
				FROM
						Deal_Line__c
				WHERE
						Deal__c IN: dealIds
						AND
						BundleId__c != null
						AND
						Rate__c = null
		];
	}
}