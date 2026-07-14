/**
 * Created by JurgitaG on 7/15/2021.
 */

@IsTest
private class TEST_FLOW_PermissionSetCheck
{
	@IsTest
	static void testWithPermission()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User uM = new User(Alias = 'standt', Email='standarduser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', Username='test111222@sonic.com');
		insert uM;
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CRMUserPsl'];
		insert new PermissionSetAssignment(AssigneeId = uM.Id, PermissionSetId = ps.Id);

		FLOW_PermissionSetCheck.PermissionSetRequest aRequest = new FLOW_PermissionSetCheck.PermissionSetRequest();
		aRequest.userId = uM.Id;
		aRequest.permissionSetName = 'CRMUserPsl';

		Test.startTest();
		List<Boolean> results = FLOW_PermissionSetCheck.checkCPQPermission(new List<FLOW_PermissionSetCheck.PermissionSetRequest>{aRequest});
		Test.stopTest();

		System.assertEquals(true, results.get(0));
	}
	@IsTest
	static void testWithoutPermission()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='SS Sales Users'];
		User uM = new User(Alias = 'standt', Email='standarduser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', Username='test111222@sonic.com');
		insert uM;

		FLOW_PermissionSetCheck.PermissionSetRequest aRequest = new FLOW_PermissionSetCheck.PermissionSetRequest();
		aRequest.userId = uM.Id;
		aRequest.permissionSetName = 'CRMUserPsl';

		Test.startTest();
		List<Boolean> results = FLOW_PermissionSetCheck.checkCPQPermission(new List<FLOW_PermissionSetCheck.PermissionSetRequest>{aRequest});
		Test.stopTest();

		System.assertEquals(false, results.get(0));
	}
}