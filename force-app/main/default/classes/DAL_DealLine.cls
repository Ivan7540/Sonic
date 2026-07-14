public class DAL_DealLine
{
	public static final String OUTRIGHT_PURCHASE_CONTRACT_TERM = 'None';

	public static List<Deal_Line__c> findDealLinesByParentIds(Set<Id> dealLineIds)
	{
		List<Deal_Line__c> dealLines =
		[
				SELECT
						Id
				FROM
						Deal_Line__c
				WHERE
						ParentLine__c IN:dealLineIds
		];

		return dealLines;
	}


	public static List<Deal_Line__c> deleteDealLinesByParentIds(Set<Id> dealLineIds)
	{
		List<Deal_Line__c> dealLines = findDealLinesByParentIds(dealLineIds);
		delete dealLines;

		return dealLines;
	}

	public static List<Deal_Line__c> getBundleDeviceLines(Id bundleId)
	{
		return
		[
				SELECT  Id,
						Deal__c,
						RelatedProduct__c,
						RelatedProduct__r.Name,
						toLabel(Product__c),
						toLabel(Device__c),
				(SELECT Id, Name, MetadataId__c FROM Child_Lines__r)
				FROM    Deal_Line__c
				WHERE   ParentLine__c = :bundleId AND RebateItem__c =NULL
		];
	}

	public static List<Deal_Line__c> getVasLines(Id dealId)
	{
		return
		[
				SELECT  Name,
						MetadataId__c
				FROM    Deal_Line__c
				WHERE   Deal__c=:dealId
				AND
				LineType__c='VAS'
		];
	}

	public static List<Deal_Line__c> getExistingDealLines(Id dealId)
	{
		return
		[
				SELECT  Id,
						Rate__c,
						ProductCode__c,
						Rate_Percentage__c,
						CardSplit__c
				FROM    Deal_Line__c
				WHERE   Deal__c=:dealId
				AND
				Rate__c != NULL
		];
	}
}