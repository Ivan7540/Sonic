/**
 * Created by simonas on 2021-08-18.
 */

public class CaseUpdateValidator implements ICaseValidator
{
	public static final String ERROR_HAS_COMPLETED_WORK_ORDER = Label.CaseCanNotBeRetractedDueToCompletedWorkOrder;

	@TestVisible
	private Set<Id> caseIdsWithCompletedWorkOrders = new Set<Id>();

	public void initialize(List<Case> updatedCases)
	{
		for (WorkOrder__c completedWorkOrder : DAL_WorkOrder.getCompetedCollectionWorkOrders(updatedCases))
		{
			this.caseIdsWithCompletedWorkOrders.add(completedWorkOrder.Order__r.RelatedCase__c);
		}
	}

	public void validate(Case oldCase, Case newCase)
	{
		if (oldCase.Status == newCase.Status)
		{
			return; // valid - existing validation is based on Status change
		}
		if (newCase.Status == DAL_Case.STATUS_CANCELLATION_RETRACTED && this.caseIdsWithCompletedWorkOrders.contains(newCase.Id))
		{
			newCase.Status.addError(ERROR_HAS_COMPLETED_WORK_ORDER);
		}
	}

	@TestVisible
	private void addCaseIdsWithCompletedWorkOrder(Case newCase)
	{
		this.caseIdsWithCompletedWorkOrders.add(newCase.Id);
	}
}