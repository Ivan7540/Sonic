/**
 * Created by JurgitaG on 7/20/2021.
 */

@IsTest(SeeAllData = true)
private class OpportunityApprovalInfoContrTest
{
	private static Opportunity opp;
	static void setup()
	{
		Account testAccount = TestDataFactory.createTestAccounts(1, 1, 'GAU')[0];
		Product2 testProd = [Select Id, NeedsTerminalId__c From Product2 Where ProductCode = 'SS_CLASSIC_24_MONTH_BUNDLE'];

		opp = TestDataFactory.createOpportunities(new List<Account>{testAccount})[0];
		List<SBQQ__Quote__c> aQuotes = TestDataFactory.createQuotes(new List<Opportunity>{opp},false);
		opp.DocumentCheckStatus__c = 'ITC Rejected';
		update opp;

	}
	@IsTest
	static void testOpportunityInApproval()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User uM = new User(Alias = 'standt', Email='standarduser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='test111222@sonic.com');
		insert uM;
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='test111@sonic.com', ManagerId=uM.Id);
		insert u;
		PermissionSetLicense psl= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' LIMIT 1];
		insert new PermissionSetLicenseAssign(AssigneeId = u.Id, PermissionSetLicenseId = psl.Id);

		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SteelBrickCPQUser' LIMIT 1];
		insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

		System.runAs(u)
		{
			setup();

			// The following code runs as user 'u'

			Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
			app.setObjectId(opp.Id);
			Approval.ProcessResult result = Approval.process(app);
		}
		List<ProcessInstanceWorkitem> approvalsInProgress = [SELECT Id FROM ProcessInstanceWorkitem];
		Test.StartTest();
		OpportunityApprovalInfoController.getOpportunityType(approvalsInProgress[0].Id);
		OpportunityApprovalInfoController.getQuoteLines(approvalsInProgress[0].Id);
		Test.StopTest();
	}
}