/**
 * Created by JurgitaG on 6/27/2021.
 */

@IsTest
private class LeadSelectionControllerTest
{
	public static void setup(){
		Lead aLead = TestDataFactory.createLead('Web');
		Lead aLead2 = TestDataFactory.createLead('Web');
	}
	@IsTest
	static void testLeadController()
	{
		Test.startTest();
		LeadSelectionController.getDuplicateLeads('test', 'test', 'test', '111222111');
		LeadSelectionController.getDuplicateContacts('test', 'test', 'test', '111222111');

		Test.stopTest();
	}
}