/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class TEST_FLOW_ConvertLead
{
	@IsTest
	static void testLeadConvert()
	{
		Lead newLead = TestDataFactory.createLead('Web');
		FLOW_ConvertLead.LeadConvertRequest aRequest= new FLOW_ConvertLead.LeadConvertRequest();
		aRequest.leadId=newLead.Id;
		aRequest.convertedStatus='Qualified';
		Test.startTest();
		FLOW_ConvertLead.convertLeads(new List<FLOW_ConvertLead.LeadConvertRequest>{aRequest});
		Test.stopTest();
		List<Account> accounts = [SELECT Id FROM Account];
		System.assertEquals(1, accounts.size());
	}
}