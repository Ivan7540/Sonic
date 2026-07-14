/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class DealApprovalInfoControllerTest
{
	private static Deal__c aDeal;
	static void setup()
	{
		aDeal = TestDataFactory.createDeals(1)[0];
		Deal_Line__c aLine = new Deal_Line__c(Product__c ='Classic',Device__c = 'SS_SP_630', ContractTerm__c='24Month', Deal__c = aDeal.Id);
		aLine.RebatedProduct__c='SS_INSTALL_TRAINING_FEE';
		insert aLine;
		aDeal.Status__c ='Quote Submitted';
		DAL_BaseObject.UpdateDBObject(aDeal);

	}
	@IsTest
	static void testDealInApproval()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='SS Sales Users'];
		User uM = new User(Alias = 'standt', Email='standarduser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='test111222@sonic.com');
		insert uM;
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='test111@sonic.com', ManagerId=uM.Id);

		System.runAs(u)
		{
			setup();

			// The following code runs as user 'u'

			Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
			app.setObjectId(aDeal.Id);
			Approval.ProcessResult result = Approval.process(app);
		}
		List<ProcessInstanceWorkitem> approvalsInProgress = [SELECT Id FROM ProcessInstanceWorkitem];
		Test.StartTest();
		DealApprovalInfoController.getDealRates(approvalsInProgress[0].Id);
		DealApprovalInfoController.getDealRebates(approvalsInProgress[0].Id);
		Test.StopTest();
	}
}