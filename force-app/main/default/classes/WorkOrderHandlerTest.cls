/**
 * Created by JurgitaG on 8/5/2021.
 */

@IsTest
private class WorkOrderHandlerTest
{
	@IsTest
	static void testEFTWorkOrder()
	{
		WorkOrder__c aWorkOrder = new WorkOrder__c();
		aWorkOrder.ProductFamily__c = DAL_Product.PRODUCT_FAMILY_EFT;
		Test.startTest();
		insert aWorkOrder;
		Test.stopTest();

		WorkOrder__c testWorkOrder = [SELECT Id, ProductFamily__c, InstallationTAT__c  FROM WorkOrder__c WHERE Id =:aWorkOrder.Id];

		System.assert(testWorkOrder.InstallationTAT__c !=null);
	}
}