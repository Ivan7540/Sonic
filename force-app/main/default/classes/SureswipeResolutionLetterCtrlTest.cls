/**
 * Created by JurgitaG on 11/15/2021.
 */

@IsTest
private class SureswipeResolutionLetterCtrlTest
{
	@isTest
	static void testResolutionLetter(){
		Account acc = TestDataFactory.createTestAccounts(1, 2, '').get(0);
		List<AccountContactRelation> relations = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE AccountId=:acc.Id];
		for (AccountContactRelation relation : relations){
			relation.Roles= 'Director';
		}
		update relations;
		List<Deal__c> deals = TestDataFactory.createDeals(1);

		deals[0].Account__c = acc.Id;
		update deals;
		String jsonString = '{"mainDirector":"'+relations.get(0).ContactId+'"}';
		SureswipeResolutionLetterController.ResolutionData resolutionData = (SureswipeResolutionLetterController.ResolutionData)JSON.deserialize(jsonString, SureswipeResolutionLetterController.ResolutionData.class);
		resolutionData.dealId = deals[0].Id;

		Test.startTest();
		PageReference pageRef = Page.SureswipeResolutionLetter;
		pageRef.getParameters().put('id', deals[0].Id);
		pageRef.getParameters().put('JSONString', jsonString);
		Test.setCurrentPage(pageRef);
		SureswipeResolutionLetterController thisController = new SureswipeResolutionLetterController();
		SureswipeResolutionLetterController.saveResolutionData(new List<SureswipeResolutionLetterController.ResolutionData>{resolutionData});
		Test.stopTest();
	}
}