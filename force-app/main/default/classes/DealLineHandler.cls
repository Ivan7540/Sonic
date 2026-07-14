/**
 * Created by ViktorijaR on 12/14/2021.
 */

public class DealLineHandler extends TH_BaseObject
{

	public override void bulkBefore()
	{
		if (Trigger.isDelete)
		{
			deleteChildDealLines(Trigger.old);
		}
	}

	public static void deleteChildDealLines(List<Deal_Line__c> parentLineDealLines)
	{
		Set<Id> parentLineIds = UTIL_System.extractListIds(parentLineDealLines);
		DAL_DealLine.deleteDealLinesByParentIds(parentLineIds);
	}
}