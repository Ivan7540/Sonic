/**
 * Created by simonas on 2021-08-18.
 */

public class DAL_WorkOrder
{
	public static final String TYPE_COLLECTION = 'Collection';

	public static final String STATUS_COMPLETED = 'Completed';

	public static List<WorkOrder__c> getCompetedCollectionWorkOrders(List<Case> cases)
	{
		return [
				SELECT
						Id,
						Order__r.RelatedCase__c
				FROM
						WorkOrder__c
				WHERE
						Type__c = :TYPE_COLLECTION
						AND
						Status__c = :STATUS_COMPLETED
						AND
						Order__r.RelatedCase__c IN :cases
		];
	}
}