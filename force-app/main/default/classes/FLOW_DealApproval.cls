/**
 * Created by JurgitaG on 9/28/2021.
 */

public class FLOW_DealApproval
{
	@InvocableMethod(label='Rates Approval' category='Deal')
	public static List<DealApprovalResult> checkRatesForApproval(List<DealApprovalRequest> requests)
	{
		List<Rate_Approval_Range__mdt> ranges =
		[
				SELECT
						Id,
						UpperBand__c,
						LowerBand__c,
						DebitRateMin__c,
						DebitRateExpected__c,
						CreditRateMin__c,
						CreditRateExpected__c,
						MarginMin__c,
						MarginExpected__c
				FROM
						Rate_Approval_Range__mdt
				ORDER BY LowerBand__c ASC
		];
		List<DealApprovalResult> results = new List<FLOW_DealApproval.DealApprovalResult>();
		for (DealApprovalRequest aRequest : requests)
		{
			Boolean needExec = false;
			Boolean needRSM = false;
			Rate_Approval_Range__mdt range = getRange(ranges, aRequest.swipe);
			String approvalMessage = '';
			if (aRequest.drValue < range.DebitRateExpected__c
					|| aRequest.crValue < range.CreditRateExpected__c
					|| aRequest.margin < range.MarginExpected__c)
			{
				needRSM = true;
				approvalMessage = 'Need RSM approval!';

			}
			if (aRequest.drValue < range.DebitRateMin__c
					|| aRequest.crValue < range.CreditRateMin__c
					|| aRequest.margin < range.MarginMin__c || ((aRequest.drValue < range.DebitRateExpected__c
					|| aRequest.crValue < range.CreditRateExpected__c) && aRequest.margin < 750))
			{
				needExec = true;
				approvalMessage = 'Need Exec approval!';

			}

			DealApprovalResult aResult = new FLOW_DealApproval.DealApprovalResult();
			aResult.needExec = needExec;
			aResult.needRSM = needRSM;
			aResult.approvalDescription = approvalMessage;
			results.add(aResult);
		}

		return results;
	}

	public static Rate_Approval_Range__mdt getRange(List<Rate_Approval_Range__mdt> ranges, Integer swipe)
	{
		for (Rate_Approval_Range__mdt range : ranges)
		{
			if (range.LowerBand__c <= swipe && swipe <= range.UpperBand__c)
			{
				return range;
			}
		}
		return ranges.get(ranges.size() - 1);
	}

	public class DealApprovalRequest
	{
		@InvocableVariable(label='Swipe value' required=true)
		public Integer swipe;
		@InvocableVariable(label='Debit Rate value' required=true)
		public Decimal drValue;
		@InvocableVariable(label='Credit Rate value' required=true)
		public Decimal crValue;
		@InvocableVariable(label='Transaction Margin value' required=true)
		public Decimal margin;

	}

	public class DealApprovalResult
	{
		@InvocableVariable(label='Need RSM')
		public Boolean needRSM;
		@InvocableVariable(label='Need Exec')
		public Boolean needExec;
		@InvocableVariable(label='Approval Description')
		public String approvalDescription;

	}


}