/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class TEST_FLOW_CreateLead
{
	@IsTest
	static void testCreateLead()
	{
		FLOW_CreateLead.LeadRequest aRequest = new FLOW_CreateLead.LeadRequest();
		aRequest.email='test@mail.com';
		aRequest.landline='5556666555';
		aRequest.phone='1112222111';
		aRequest.lastname = 'Test';
		aRequest.firstname = 'Test';
		aRequest.company ='Test';

		Test.startTest();
		FLOW_CreateLead.createLead(new List<FLOW_CreateLead.LeadRequest>{aRequest});
		Test.stopTest();
		List<Lead> aLeads = [SELECT Id FROM Lead];
		System.assertEquals(1, aLeads.size());
	}
}